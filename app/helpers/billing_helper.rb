require 'active_merchant'

module BillingHelper
    include ActiveMerchant
    include LocationHelper

    PAYMENT_TYPES = {
        :visa       => { :name => "Visa", :type => :card },
        :mastercard => { :name => 'Mastercard', :type => :card },
        :amex       => { :name => 'American Express', :type => :card }
    }.freeze

    PAYMENT_OPTIONS = PAYMENT_TYPES.to_a.collect{|elem| [elem[1][:name], elem[0]]}.sort{|a,b| a[0] <=> b[0]}.freeze

    BILLING_PROVINCES = {
        'AB' => 'Alberta',
        'BC' => 'British Columbia',
        'MB' => 'Manitoba',
        'NB' => 'New Brunswick',
        'NL' => 'Newfoundland/Labrador',
        'NT' => 'Northwest Territories',
        'NS' => 'Nova Scotia',
        'ON' => 'Ontario',
        'PE' => 'PEI',
        'QC' => 'Quebec',
        'SK' => 'Saskatchewan',
        'YT' => 'Yukon'
    }

    BILLING_PROVINCES_OPTIONS_FOR_SELECT = BILLING_PROVINCES.sort{|x,y| x[0] <=> y[0]}.collect{|x| x.reverse}

    class Config

        def self.gateway=(name)
            @@gateway = name.is_a?(Symbol) ? name : name.to_sym
        end

        def self.create_gateway
            ActiveMerchant::Billing::Base.gateway(@@gateway).new(@@gateway_params[@@gateway])
        end

        def self.test_mode
            ActiveMerchant::Billing::Base.mode = :test
        end

        def self.braintree_credentials(username, password)
            @@gateway_params ||= {}
            @@gateway_params[:braintree] = {:login => username, :password => password}
        end


    end

    class BillingInfo

        attr_reader     :first_name, :last_name, :phone_number
        attr_reader     :address, :address2, :city, :state_province, :country, :postal_code
        attr_reader     :payment_type
        attr_reader     :card_number, :card_month, :card_year, :card_verification
        attr_reader     :authorization, :authorization_amount

        #=======================================================================
        #
        # Construction
        #
        #=======================================================================

        def initialize(*attributes)

            # Create a default billing info
            if attributes.empty?
                @payment_type = PAYMENT_OPTIONS[0][1]
                return
            end

            # Validate args
            throw ArgumentError.new unless (attributes.length <= 2) && attributes[0].is_a?(Hash)

            # Set properties
            attributes[0].each_pair do |k,v|
                instance_variable_set("@#{k}".to_sym, v)
            end

            if (attributes.length > 1)
                loc = attributes[1]
                unless loc.nil?
                    ::LocationHelper::Location.assert_location_arg(loc)
                    lat, lng, @address, @address2, @city, @state_province, @postal_code, @country = loc.to_array
                end
            end

            @payment_type = @payment_type.to_sym if (@payment_type.is_a?(String))
            throw ArgumentError.new('Invalid payment type') unless PAYMENT_TYPES.has_key?(@payment_type)

            # Special case for splitting a full name to first & last name
            if !@name.nil? && @first_name.nil?
                @first_name, @last_name = @name.split(' ', 2)
            end

            # Create additional info based on payment type
            case PAYMENT_TYPES[@payment_type][:type]
            when :card
                @credit_card = ActiveMerchant::Billing::CreditCard.new(
                    :number     => @card_number,
                    :month      => @card_month.to_i,
                    :year       => @card_year.to_i,
                    :verification_value => @card_verification,
                    :first_name => @first_name,
                    :last_name  => @last_name,
                    :type       => PAYMENT_TYPES[@payment_type][:name]
                )
            else
                throw NotImplementedError.new
            end

            @gateway_options = {
                :billing_address => {
                    :address1 => @address,
                    :address2 => @address2,
                    :city => @city,
                    :state => @state_province,
                    :country => ActiveMerchant::Country.find('Canada').code(:alpha2),
                    :zip => @postal_code,
                    :phone => @phone_number
                },
                :currency => 'CAD'
            }

        end

        #=======================================================================
        #
        # Validation support
        #
        #=======================================================================

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

        private

        def validate

            unless @credit_card.nil? || @credit_card.valid?
                
                attr_map = {
                    :number     => :card_number,
                    :month      => :card_month,
                    :year       => :card_year,
                    :first_name => :first_name,
                    :last_name  => :last_name,
                    :verification_value => :card_verification,
                    :type       => :payment_type
                }

                @credit_card.errors.each do |attr,msgs|
                    throw "Unmapped credit card attribute '#{attr}' in errors" unless attr_map.has_key?(attr.to_sym)
                    msgs.each {|msg| self.errors.add(attr_map[attr.to_sym], msg)}
                end
                
            end

        end

        #=======================================================================
        #
        # Billing support
        #
        #=======================================================================
        
        public
        
        def authorize?(amount_in_dollars)
            
            amount = (amount_in_dollars * 100).to_i

            response = gateway.authorize(amount, @credit_card, @gateway_options)
            if response.success?
                 @authorization = response.authorization
                 @authorization_amount = amount
                 return true
            else
                self.errors.add_to_base(reponse.message)
                return false
            end

        end

        def complete!
            gateway.capture(@authorization_amount, @authorization, @gateway_options)
            @authorization = nil
        end

        def void!
            gateway.void(@authorization)
            @authorization = nil
        end

        private

        def gateway
            @gateway ||= Config.create_gateway
        end


    end
    

end
