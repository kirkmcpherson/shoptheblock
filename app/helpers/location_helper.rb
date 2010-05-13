module LocationHelper
    require 'geokit'
    
    #
    #  Constants
    #
    GOOGLE_MAPS_SCRIPT_URL='http://maps.google.com/maps?file=api&amp;v=2&amp;sensor=false&amp;key=%1$s'

    class Location
        include ::Geokit::Geocoders

        #=== BEGIN VALIDATION INIT ===#
        private

        def save
            throw NotImplementedError.new
        end

        def save!
            throw NotImplementedError.new
        end

        def new_record?
            false
        end

        public

        def self.human_attribute_name(attribute_key_name, options={})
            default = attribute_key_name.humanize
            I18n.translate(default, :default => default)
        end

        include Validatable
        #=== END VALIDATION INIT ===#

        attr_reader     :lat
        attr_reader     :lng
        attr_reader     :address
        attr_reader     :address2
        attr_reader     :city
        attr_reader     :postalcode
        attr_reader     :province
        attr_reader     :country

        validates_presence_of :lat, :lng, :address, :city, :postalcode, :province, :country

        def initialize(*params)
            params.flatten!
            unless params.empty?
                @lat, @lng, @address, @address2, @city, @province, @postalcode, @country = params
                @lat, @lng = @lat.to_f, @lng.to_f
            end
        end

        def valid?
            !@lat.nil?
        end

        def self.from_address(address)

            loc = GoogleGeocoder.geocode(address)

            return loc.success ? Location.new(loc.lat, loc.lng, loc.street_address, '', loc.city, loc.state, loc.zip, loc.country_code) : Location.new()

        end

        def self.from_cookie(cookie)
            Location.new(cookie.split('|'))
        end

        def self.from_form(fields)
            Location.new(
                    fields[:lat],
                    fields[:lng],
                    fields[:address],
                    fields[:address2],
                    fields[:city],
                    fields[:province],
                    fields[:postalcode],
                    fields[:country]
                )
        end

        def to_cookie
            to_array.join('|')
        end

        def latlng
            [@lat, @lng]
        end

        def full_address
            result = ''

            [@address, @address2, @city, @province, @postalcode, @country].each do |val|
                unless val.blank?
                    result += ", " unless result.empty?
                    result += val
                end
            end

            return result
        end

        def display_address
            result = ''
            
            [@address, @address2, @city, @province, @postalcode].each do |val|
                unless val.blank?
                    result += ", " unless result.empty?
                    result += val
                end
            end

            return result
        end

        def to_s
            display_address
        end

        def to_array
            [@lat, @lng, @address, @address2, @city, @province, @postalcode, @country]
        end

        def self.assert_location_arg(var)

            throw ArgumentError.new('Location argument cannot be nil') if var == nil
            throw ArgumentError.new('Location argument is not a Location object') unless var.is_a?(::LocationHelper::Location)

        end
    end

    module ActiveRecord

        module ClassMethods

            def has_location(*options)

                if options.empty? || options[0].is_a?(Hash)
                    prefix = ''
                else
                    prefix = "#{options[0].to_s}_"
                    options.shift

                end

                options = options.shift
                options ||= {}

                attribute_name = "#{prefix}location".to_sym
                 logger.info (" has location   #{options.to_a}")
                throw ArgumentError.new('Invalid options (expected Hash)') unless options.is_a?(Hash)

                composed_of(
                    attribute_name,
                    :mapping => %w{lat lng address address2 city province postalcode country}.collect{|s| [ "#{prefix}#{s}", s ]},
                    :class_name => '::LocationHelper::Location',
                    :allow_nil => true,
                    :converter => proc do |val|
                        if val.is_a?(String)
                            ::LocationHelper::Location.from_address(val)
                        elsif val.is_a?(Hash)
                            ::LocationHelper::Location.from_form(val)
                        else
                            throw ArgumentError.new("Cannot convert #{val.class} to Location")
                        end
                    end
                )

                send(validation_method(:save), {:allow_nil=>true}) do |record|
                   val = record.send(attribute_name)                 
                    # modify late
                   begin
                         method = record.method('address')
                         method2  = record.method('online?')
                         # store would be validate only if the store is noe online and does not have an address
                         record.errors.add(attribute_name, "is invalid") if (record.address.blank? && record.online?)
                   rescue NameError
                          record.errors.add(attribute_name, "is invalid") unless val.nil? || val.valid?
                   end
                end

                #validates_associated "#{prefix}location".to_sym

                unless options[:mappable] == false
                    acts_as_mappable(
                        :lat_column_name => "#{prefix}lat",
                        :lng_column_name => "#{prefix}lng"
                      )
                end

#                mappable_options = {}
#                if (options.fetch(:auto_geocode, false) == true)
#                    mappable_options[:auto_geocode] = { :field => :address, :error_message => 'is not a valid location' }
#                end

                #acts_as_mappable #(mappable_options)


            end

            def assert_location_arg(var)

                Location.assert_location_arg(var)

            end
            
        end
    end

    module ActionView

        module InstanceMethods

            # Creates a div for the client-side map and calls the
            # Google API to initialize it. Any markers that were added
            # before the map was created will also be added at this time.
            def create_map(div_id, center_location, *options)
		
                options.insert(0, :id => div_id)
		
                concat(content_tag(:div, '', *options))
                concat(javascript_tag(%{
                    Google_InitMap('#{div_id}', #{center_location.lat}, #{center_location.lng});
                }))

            end

            # Adds a marker to the current map with an optional
            # custom image and popup content block
            def add_map_marker(location, marker_image=nil, link_id=nil, &block)

                if marker_image == nil
                    marker_path = 'null'
                else
                    marker_path = "#{root_url}images/#{marker_image}"
                end

                if (block_given?)
                    html = escape_javascript(capture(&block))
                else
                    html = ''
                end

                concat(javascript_tag(%{
                    Google_AddMarker(
                        #{location.lat},
                        #{location.lng},
                        '#{marker_path}',
                        '#{html}',
                        #{link_id.nil? ? 'null' : array_or_string_for_javascript(link_id)}
                    );
                }))

            end

            def mapped_content_tag(name, location, options={}, &block)

                marker_image = options[:marker]
                options[:marker] = nil

                @content_for_popup = nil
                content_html = capture(&block)

                options[:id] = "mapped_tag_#{(rand * 0xffffffff).to_i}" unless options[:id]

                content_options = { :id => options[:id] }.merge(options[:content] || {})

                concat(content_tag(
                        name,
                        content_html,
                        content_options
                    ))

                popup_options = options[:popup]
                popup_html = content_tag(:div, @content_for_popup || content_html, popup_options)

                add_map_marker(location, marker_image, options[:id]) { popup_html }

            end

            # Removes all markers from the client-side map
            def clear_map_markers()

                concat(javascript_tag(%{
                    Google_ClearMarkers();
                }))

            end

            def include_map_scripts
                throw 'Constant GOOGLE_API_KEY must be defined with your Google API key' unless defined?(GOOGLE_API_KEY)

                [
                    # Include the Google Maps API
                    # Note that we can't use javascript_include_tag because
                    # it automatically adds a .js extension which screws this up
                    content_tag(
                        :script,
                        '',
                        :src => sprintf(GOOGLE_MAPS_SCRIPT_URL, GOOGLE_API_KEY),
                        :type => 'text/javascript'
                    ),

                    # Include our client-side script
                    javascript_include_tag('google'),

                    javascript_tag('Google_Load();'),

                    javascript_tag('Google_Unload();', :for => 'window', :event => 'onunload')

                ].join("\n")
            end

        end

    end

    module ActionController

        module ClassMethods


        end

        module InstanceMethods

            @location = nil

            # Retrieves the current location from the request cookies or
            # the currently logged in user. Returns nil if no location was
            # found
            def get_location

                if (cookies[:location] != nil)
                    @location = Location.from_cookie(cookies[:location])
                elsif (logged_in? == true)
                    @location = current_user.location
                else
                    @location = nil
                end

                return @location
            end

            # Same as get_location, but redirects the page if no location
            # was found
            def get_location_or_redirect(options = {})
                redirect_to(options) if get_location() == nil
            end

            # Saves the current location to the response cookies
            def save_location

                if @location != nil
                    cookies[:location] = @location.to_cookie
                end

            end

            def set_location_to(obj)
                Location.assert_location_arg(obj)
                @location = obj
            end

        end

    end

    ::ActionView::Base.class_eval do
        include(LocationHelper::ActionView::InstanceMethods)
    end

    ::ActiveRecord::Base.class_eval do
        extend(LocationHelper::ActiveRecord::ClassMethods)
    end

    ::ActionController::Base.class_eval do
        include(Geokit::Geocoders)
        extend(LocationHelper::ActionController::ClassMethods)
        include(LocationHelper::ActionController::InstanceMethods)
    end

end
