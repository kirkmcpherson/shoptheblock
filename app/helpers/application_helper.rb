# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    #
    # User interface helpers
    #
    NAMES_OF_DAYS = %w{Monday Tuesday Wednesday Thursday Friday Saturday Sunday}
    
    EMAIL_ADDRESS = {
      :info => 'info@shoptheblock.ca',
      :admin => 'admin@shoptheblock.ca'
    }

    def names_of_days
        # Abstract constant so we can possibly localize if needed
        NAMES_OF_DAYS
    end

    def heading_tag(heading_text)
        #content_tag(:h3 ) do
        content_tag(:h3, :class=>"greenHeading" ) do          
            #concat image_tag('white_star.png', :align=>'absmiddle')
            concat h(' ' + heading_text)
        end   
    end
    


    def link_to_cancel(back_url=nil, options={})
        back_url ||= root_path
        options.assert_valid_keys(:cancel_key, :allow_back)

        if options[:allow_back] == true
            back_url = session[:last_page] unless session[:last_page].nil?
        end

        link_to_function(
            t(options[:cancel_key] || 'input.cancel'),
            "window.location='#{back_url}'"
        )
    end

    def submit_tags(options={})
        throw ArgumentError.new unless options.is_a?(Hash)
        options.assert_valid_keys(:submit_key, :submitted_key, :cancel_key, :cancel_url, :allow_back)

        return t(
            'input.submit_or_cancel',
            :submit => submit_tag(
                t(options[:submit_key] || 'input.submit'),
                :onclick => %{
                    this.disabled = true;
                    this.value = '#{t(options[:submitted_key] || 'input.submitted')}';
                    $(this).next().hide();
                    this.form.submit();
                }
            ),
            :cancel => link_to_cancel(
                options[:cancel_url],
                options.reject{|k,v| ![:allow_back,:cancel_key].include?(k) }
            )
        )
    end

    def load_legal_agreement
        t('legal')
    end

    def admin_logged_in?
        logged_in? && current_user.administrator?
    end

    def url_escape(text)
      html_escape(text).gsub(/\s/) do |s|
        case s
        when ' '
          '%20'
        when "\n"
          '%0D%0A'
        else
          s
        end
      end
    end

    def email_link(type, text=nil, options={})
      raise ArgumentError.new("Invalid email address type") unless EMAIL_ADDRESS.key?(type)

      url = "mailto:"
      url << EMAIL_ADDRESS[type]
      url << "?subject=#{url_escape(options[:subject])}" if options.key?(:subject)
      url << "&body=#{url_escape(options[:body])}" if options.key?(:body)

      text ||= EMAIL_ADDRESS[type]

      link_to(text, url)

    end

    def sort_th text, param, target, default=false
      img = if params[:sort] == param || default
              image_tag('arrow-down.gif')
            elsif params[:sort] == param + '_reverse'
              image_tag('arrow-up.gif') 
            else
              ''
            end

      content_tag :th, :style => 'white-space:nowrap;' do 
        sort_link(text, param, target) + img
      end
    end

    def sort_link text, param, target
      key = param
      key += "_reverse" if params[:sort] == param
      options = {
        :url => { :action => 'index',  :params => params.merge({:sort => key, :mode => :view }) },
        :method => :get,
        :update => target
      }
      html_options = {
        :title => "Sort by this field",
        :method => :get,
        :href => url_for(:action => 'index', :params => params.merge({:sort => key, :mode => :view }))
      }
      link_to_remote(text, options, html_options)
    end

    def validation_errors(*args)
        options = args.last.is_a?(Hash) ? args.pop.symbolize_keys : {}
        objects = args.compact
        return '' if objects.all? { |obj| obj.errors.empty? }
        sub = options[:sub] || {}
        message = options.include?(:message) ? options[:message] : "There were problems with the following fields:"
        
        xml = Builder::XmlMarkup.new
        xml.div :id => 'errorExplanation', :class => 'errorExplanation' do
          xml.h2 "Unable to complete request due to the following errors"
          xml.p message
          xml.ul do
            objects.each do |obj|
              obj.errors.each do |name, msg|
                substitute = sub.find { |k, v| k.to_s.humanize == name.to_s.humanize }
                name = substitute.last if substitute
                xml.li "#{name.to_s.humanize} #{msg}"
              end
            end
          end
        end
      end
end
