# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    include AuthenticatedSystem
    include ExceptionNotifiable
    helper :all # include all helpers, all the time

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery # :secret => 'c7d3b658d7d08aa0eb07fb5492b0f6f4'
  
    # See ActionController::Base for details
    # Uncomment this to filter the contents of submitted sensitive data parameters
    # from your application log (in this case, all fields with names like "password").
    # filter_parameter_logging :password

    prepend_before_filter proc{|controller| controller.set_web_root }

    PARTNER_MEMBERSHIP_COST = 10  # Should be moved to site settings...

    def set_web_root
        # Using the current request, save the root URL so other parts
        # of the site can easily construct absolute URLs
        ENV['WWW_ROOT'] = root_url
    end

    Paperclip::Attachment.default_options.merge!({
            :url => "/photos/:class/:id/:attachment/:style.:extension",
            :path => ":rails_root/public/photos/:class/:id/:attachment/:style.:extension",
            :default_url => "/images/:class_:attachment_:style.png",
            :styles => { :thumb=> "60x60#", :small  => "150x150>" },
            :default_style => :thumb
        })


    #
    # Authorization helpers
    #
    private
    def self.add_requires_role_filter(role, options)
        throw ArgumentError.new("Invalid role in requires_role.") unless User::ROLES::has_key?(role)
        throw ArgumentError.new("Expected hash for for role options") unless options.is_a?(Hash)

        append_before_filter("requires_#{role}_role".to_sym, options)
    end

    protected
    def reject_request
        render :text => 'Unauthorized 401', :status => 401
    end

    public
    # Requires user to be logged in and be an administrator
    def requires_administrator_role
        reject_request unless logged_in? && current_user.administrator?
    end

    # Requires user to be logged in and either be a merchant or administrator
    def requires_merchant_role
        reject_request unless logged_in? && current_user.merchant?
    end

    # Requires user to be logged in and either be a member or administrator
    def requires_member_role
        reject_request unless logged_in? && current_user.member?
    end

    def validate_user(user_id, allow_admin=true)
        if logged_in? && ((allow_admin && current_user.administrator?) || (current_user.id == user_id.to_i))
            return true
        else
            reject_request
            return false
        end
    end

    def self.requires_role(*options)

        throw ArgumentError.new('Missing role name in requires_role') if options.empty?

        role = options.shift
        options = options.shift || {}

        add_requires_role_filter(role, options)

    end

    # Call this at the top of a controller to enable TinyMCE for that controller
    def self.tiny_mce
        uses_tiny_mce :options => { :plugins => %w{contextmenu paste tabfocus},
                                    :theme                           => 'advanced',
                                    :theme_advanced_toolbar_location => 'top',
                                    :theme_advanced_toolbar_align    => 'left',
                                    :theme_advanced_buttons1         => 'bold,italic,underline,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,link,hr',
                                    :theme_advanced_buttons2         => 'fontselect,fontsizeselect,forecolor,backcolor,pasteword',
                                    :theme_advanced_buttons3         => '',
                                    :entity_encoding                 => 'raw',
                                    :document_base_url               => 'http://www.shoptheblock.ca/',
                                    :relative_urls                   => false,
                                    :convert_urls                    => false
                                  }
    end


    def paypal_encrypted(num_cards, cost, address, renewal=false, gift=false)

      amount = cost
      amount += PARTNER_MEMBERSHIP_COST if num_cards > 1
      item_name = renewal ? "#{t('site_name')} Renewal" : "#{t('site_name')} Membership"
      item_name += " with an Extra Membership Card" if num_cards > 1
      
      if(renewal)
        return_url = return_from_paypal_renewal_url(:code => @user.activation_code) 
      elsif gift
        return_url = return_from_paypal_gift_url(:code => @user.activation_code)        
      else
        return_url = return_from_paypal_url(:code => @user.activation_code)        
      end
      
      notify_url = defined?(PAYPAL_INBOUND_URL) \
        ? "#{PAYPAL_INBOUND_URL}/verify/#{@user.activation_code}?gift=#{gift}" \
        : verify_payment_url(:code => @user.activation_code, :gift => gift)

          
      
      if renewal
        return_url += "?renew=true"
        notify_url += "?renew=true"
      end

      values = {
        :business   => PAYPAL_EMAIL,
        :cmd        => '_xclick',
        :item_name  => item_name,
        :currency_code => "CAD",
        :amount     => amount,
        :return     => return_url,
        :rm         => 1,
        :tax_rate    =>   SiteSettings.get.tax_percent,
        :notify_url => notify_url,
        :cert_id    => PAYPAL_CERT_ID,
        :first_name => gift == true ? @user.gift_giver_first_name : @user.first_name,
        :last_name  => gift == true ? @user.gift_giver_last_name : @user.last_name,
        :email      =>     gift == true ? @user.gift_giver_email : @user.email
      }
      values.merge!({ #:address_override => "1",
          :address1 => address[:address],
          :address2 => address[:address2],
          :city => address[:city],
          :state => address[:province],
          :country => "CA",
          :zip => address[:postalcode] }) if address
      logger.debug( values.map { |k,v| "#{k}=#{v}" }.join("\n") )
      encrypt_for_paypal(values)
    end

    def encrypt_for_paypal(values)
      paypal_cert_pem = File.read("#{Rails.root}/certs/#{PAYPAL_CERT}")
      app_cert_pem = File.read("#{Rails.root}/certs/app_cert.pem")
      app_key_pem = File.read("#{Rails.root}/certs/app_key.pem")

      signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(app_cert_pem), OpenSSL::PKey::RSA.new(app_key_pem, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
      OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(paypal_cert_pem)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
    end

end
