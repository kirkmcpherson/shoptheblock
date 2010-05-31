
require 'digest/sha1'

    
class User < ActiveRecord::Base
    include Authentication
    include Authentication::ByPassword
    include Authentication::ByCookieToken

    before_create :make_activation_code

    validate :promo_code_must_be_valid, :if => Proc.new { |user| user.new_record? }

    #validates_presence_of :phone_number, :if => Proc.new { |user| user.role != :newsletter_only }

    validates_presence_of :partner_first_name, :partner_last_name, :if => Proc.new { |user| user.card_num == 2 }

    validates_presence_of :shipping_address, :shipping_city, :shipping_province, :shipping_postalcode, 
                          :if => :not_administrator?, 
                          :unless => :validate_gift_form?

    validates_presence_of :gift_address, :gift_city, :gift_province, :gift_postalcode, 
                          :if => :validate_gift_form?

    #===========================================================================
    # CONSTANTS
    #===========================================================================

    ROLES = {
        :member         => 0,
        :merchant       => 1,
        :administrator  => 2,
        :newsletter_only => 3
    }

    NewsletterPreference = {
        :never          => 0,
        :weekly         => 1
    }

    EmailFormat = {
        :text           => 0,
        :html           => 1
    }

    StatusFlags = {
        :default        => 0,
        :needs_card     => 1 << 0,
        :expired        => 1 << 1,
        :pending        => 1 << 2,
        :renewing       => 1 << 3,
        :pending_gift   => 1 << 4
    }

    HEARD_ABOUT_FROM = [
      :friend,
      :merchant,
      :television,
      :newspaper,
      :magazine,
      :internet,
      :other
    ]

    MEMBER_ID_BASE      = 400000

    #===========================================================================
    # NAMED SCOPES
    #===========================================================================

    named_scope :newsletter_recipients, { :select => "id, first_name, last_name, email, membership_expiration, status, email_format, user_type, activation_code, newsletter",
                                          :conditions => [
                                              "((user_type = ?) AND (DATEDIFF(membership_expiration, CURDATE()) >= 0) AND (newsletter = ?)) OR user_type = ?",
                                              ROLES[:member],
                                              NewsletterPreference[:weekly],
                                              ROLES[:newsletter_only]
                                          ],
                                          :order => 'users.last_name, users.first_name' }

    named_scope :active_members, { :select => "id, first_name, last_name, email, membership_expiration, status, email_format, newsletter, partner_first_name,partner_last_name,partner_email ",
                                   :conditions => [ "(user_type = ?) AND (DATEDIFF(membership_expiration, CURDATE()) >= 0)", ROLES[:member] ],
                                   :order => 'users.last_name, users.first_name, users.email' }

    named_scope :non_member_newsletter_recipients, { :select => "id, first_name, last_name, email, membership_expiration, status, email_format, user_type, activation_code, newsletter",
                                                     :conditions => [ "user_type = ?", ROLES[:newsletter_only] ],
                                                     :order => 'users.last_name, users.first_name, users.email' }

    named_scope :non_merchant, { :conditions => "users.user_type <> #{ROLES[:merchant]}" }
    named_scope :non_admin,    { :conditions => "users.user_type <> #{ROLES[:administrator]}" }

    named_scope:only_newsletters , { :conditions => "users.user_type <> #{ROLES[:newsletter_only]}"}
  
    #===========================================================================
    # Associations
    #===========================================================================

    has_location                :neighbourhood
    has_location                :shipping, :mappable => false
    has_location                :gift, :mappable => false

    has_and_belongs_to_many     :categories

    belongs_to                  :promo_code   

    #===========================================================================
    # Validation
    #===========================================================================

    # Note that allows_blank is set to true for some of these so that we don't
    # complain that a field is both missing and not long enough and the wrong
    # format and...

    validates_presence_of       :email, :user_type
    validates_presence_of       :first_name, :last_name, :if => proc{|u| u.member?(false) }

    validates_length_of         :first_name,    :in => 2..50, :allow_blank => true
    validates_format_of         :first_name,    :with => /[a-z]+/i,  :message => Authentication.bad_name_message, :allow_blank => true
    validates_length_of         :last_name,     :in => 2..50, :allow_blank => true
    validates_format_of         :last_name,     :with => /[a-z]+(?:[\-\s\'][a-z])*/i,  :message => Authentication.bad_name_message, :allow_blank => true
    validates_length_of         :email,         :within => 6..100, :allow_blank => true #r@a.wk
    validates_format_of         :email,         :with => Authentication.email_regex, :message => Authentication.bad_email_message, :allow_blank => true
    validates_inclusion_of      :user_type,     :in => ROLES.values
   # validates_presence_of       :membership_expiration, :if => proc {|u| u.member?(false) }

    validates_presence_of       :categories, :message => 'You must select at least one category', :unless => proc {|u| !u.is_role?(:member) || u.validate_gift_form?}

    # According  Lauren Wise email : "HOWEVER, I still cannot remove/delete a spouse card name and or delete a second person entirely once the original file has been created with a spouse name"
    # May be  she would change her mind in the future.
    validates_format_of            :partner_first_name ,  :with => /[a-z]+(?:[\-\s\'][a-z])*/i,  :message => Authentication.bad_name_message, :allow_blank => true
    validates_format_of            :partner_last_name ,  :with =>  /[a-z]+(?:[\-\s\'][a-z])*/i,  :message => Authentication.bad_name_message, :allow_blank => true
    validates_format_of            :partner_email,         :with => Authentication.email_regex, :message => Authentication.bad_email_message, :allow_blank => true

    validate_on_create do |user|
      other = User.find_by_email(user.email) if user.email?
      unless other.nil? || other.can_overwrite?
        user.errors.add('email', 'is already in use')
      end
    end

    # DON'T FORGET TO UPDATE THIS WHEN ADDING NEW PROPERTIES OR
    # ACTIVERECORD WILL IGNORE THE NEW VALUES IN THE OBJECT CONSTRUCTOR
    attr_accessible(
        :email,
        :first_name,
        :last_name,
        :phone_number,
        :password,
        :password_confirmation,
        :neighbourhood_location,
        :shipping_location,
        :category_ids,
        :email_format,
        :newsletter,
        :partner_name,
        :card_num,
        :date_card_requested,
        :date_card_shipped,
        :heard_about_from,
        :heard_about_from_name,
        :promo_code_code,
        :search_distance,
        :partner_email,
        :partner_first_name,
        :partner_last_name,
        :gift_start_date,
        :gift_giver_first_name,
        :gift_giver_last_name,
        :gift_giver_email,
        :gift_location,
        :gift_address_is_receivers,
        :validate_gift_form,
         :membership_expiration,
         :gift_shipping_first_name,
         :gift_shipping_last_name,
         :partner_newsletter,
         :member_since,
          :created_at
        )

    attr_accessor :validate_gift_form

    #===========================================================================
    #
    # Account properties and methods
    # 
    #===========================================================================

    # Creates a new user object
    def self.initialize_user(user_params, membership_length=12, role = :member)
      # Allow re-use of existing user if payment wasn't completed
      user = User.find_by_email(user_params[:email])
      unless user.nil? || user.can_overwrite?
        user = nil
      end

      user = User.new() unless user
      user.role = role
      user.attributes = user_params
      user.pending!     
      user.partner_name = "#{user.partner_first_name} #{user.partner_last_name}" if user.card_num == 2
      user.date_card_requested = Time.zone.now    

      user.copy_gift_address_to_shipping_address if user.gift_address_is_receivers && !user.gift_address.blank?
      return user
    end

    def copy_gift_address_to_shipping_address
      self.shipping_address = self.gift_address
      self.shipping_address2 = self.gift_address2
      self.shipping_city = self.gift_city
      self.shipping_province = self.gift_province
      self.shipping_postalcode = self.gift_postalcode
      self.shipping_country = self.gift_country
    end
    
    # Check user referrals
    def check_referrals(referrals)
      success = true
      unless referrals.blank?
        existing_members = User.find(
          :all,
          :conditions => ['email IN (?) AND user_type <> ?', referrals, User::ROLES[:newsletter_only]],
          :select => 'id, email'
        )

        referrals.each_index do |i|
          referral = referrals[i]
          unless referral.blank?
            if !Authentication.email_regex.match(referral)
              self.errors.add_to_base(I18n.translate('users.create.referral_invalid', :email => referral))
              referrals[i] = "!" + referral
              success = false
            elsif user.email.casecmp(referral) == 0
              self.errors.add_to_base(I18n.translate('users.create.referral_self'))
              referrals[i] = "!" + referral
              success = false
            elsif (!existing_members.select{ |u| u.email.casecmp(referral) == 0 }.empty?)
              self.errors.add_to_base(I18n.translate('users.create.referral_exists', :email => referral))
              referrals[i] = "!" + referral
              success = false
            end
          end
        end
      end

      return success
    end
    

     # set partner information before update user details
    def update_extra_card_info user
      if  user[:partner_first_name].blank? || user[:partner_last_name].blank?
        self.partner_name = nil
      else
        self.partner_name  = "#{user[:partner_first_name] } #{user[:partner_last_name]}"
      end
      
      self.partner_newsletter = user[:newsletter]
    end
    
    def signed_up!
      self.renew
      self.save       
    end
    
    def signed_up_gift!
      self.validate_gift_form = true
      self.pending_gift!
      
      if !self.save
        logger.error("Error: #{self.errors.inspect}")
      end
      
      #UserMailer.deliver_gift_purchased(self)
    end
    
    # Activates the user in the database.
    def activate!
        @activated = true
        self.activated_at = Time.now.utc
        self.activation_code = nil
        save(false)
    end

    # Returns true if the user has just been activated.
    def recently_activated?
        @activated
    end

    def active?
        # the existence of an activation code means they have not activated yet
        activation_code.nil?
    end

    # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
    def self.authenticate(email, password)
        return nil if email.blank? || password.blank?
        u = find_by_email(email)
        (u && !u.pending? && u.authenticated?(password)) ? u : nil
    end

    def self.pending?(email)
      
      u = find_by_email(email)
      u && (u.pending? || u.renewing?)

    end

    def self.expired?(email)
      
      u = find_by_email(email)
      u && (u.expired?)

    end

    def email=(value)
        write_attribute :email, (value ? value.downcase : nil)
    end

    def member_id
        MEMBER_ID_BASE + self.id
    end

    def full_name
        "#{self.first_name} #{self.last_name}"
    end

    def full_name_and_email
        if first_name or last_name
            "#{full_name.strip} (#{email})"
        else
            email
        end
    end

    def set_status!(*flags)
      set_status(*flags)
      self.save! if changes['status'] && (changes['status'].first != changes['status'].last)
    end

    def set_status(*flags)
      new_status = self.status
      flags.each do |f|
          if f.is_a?(Symbol)
              new_status |= StatusFlags[f]
          elsif f.is_a?(Hash) && f[:clear]
              ([]<<f[:clear]).flatten.each do |cf|
                  new_status &= ~(StatusFlags[cf])
              end
          end
      end

      self.status = new_status
    end

    def has_status?(*flags)
      mask = 0
      flags.each {|f| mask |= StatusFlags[f] }
      (self.status & mask) == mask
    end

    def name
      first_name + " " + last_name
    end

    def can_overwrite?
      self.pending? || self.is_role?(:newsletter_only) || self.pending_gift?
    end

    def gift_giver_name
      gift_giver_first_name + " " + gift_giver_last_name
    end

    def gift_shipping_full_name
      "#{self.gift_shipping_first_name}  #{self.gift_shipping_last_name}"
    end

    def is_a_renewal?
        @renewal = false
        
        if(!date_card_requested.nil? && !member_since.nil?)
          if(date_card_requested.to_date != member_since.to_date)
            @renewal = true
          end
        end
    end

    protected

    def make_activation_code
        self.activation_code = self.class.make_token
    end

    public
    
    #===========================================================================
    #
    # Gift methods
    # 
    #===========================================================================

    def valid_gift_fields?
      success = true
      # Validate that gift fields are filled out
      if self.gift_start_date.blank?
        self.errors.add(:gift_start_date, I18n.translate('users.gift.start_date') )
        success = false
      end
      if self.gift_giver_first_name.blank?
        self.errors.add(:gift_giver_first_name, I18n.translate('users.gift.first_name') )
        success = false
      end
      if self.gift_giver_last_name.blank?
        self.errors.add(:gift_giver_last_name, I18n.translate('users.gift.last_name'))
        success = false
      end
      if self.gift_giver_email.blank?
        self.errors.add(:gift_giver_email, I18n.translate('users.gift.email'))
        success = false
      end
      if self.gift_shipping_first_name.blank?
        self.errors.add(:gift_shipping_first_namel, I18n.translate('users.gift.first_name'))
        success = false
      end
      if self.gift_shipping_last_name.blank?
        self.errors.add(:gift_shipping_last_name, I18n.translate('users.gift.last_name'))
        success = false
      end
 
      return success
    end
    
    
    def validate_gift_form?
      validate_gift_form
    end




    #===========================================================================
    #
    # Role properties and methods
    #
    #===========================================================================



    def role=(value)
        self.user_type = ROLES[value]
    end

    def role
        ROLES.each_pair { |k,v| return k if v == self.user_type }
        throw RuntimeError.new('User has been assigned an invalid role')
    end

    def is_role?(role)
        return self.user_type == ROLES.fetch(role)
    rescue IndexError
        throw ArgumentError.new('Invalid role')
    end

    def administrator?
        is_role?(:administrator)
    end

    def not_administrator?
        !administrator?
    end

    def merchant?(allow_admin=true)
        is_role?(:merchant) || (allow_admin && administrator?)
    end

    def member?(allow_admin=true)
        is_role?(:member) || (allow_admin && administrator?)
    end

    named_scope :only_members, :conditions => ['user_type = ?', User::ROLES[:member]]

    #===========================================================================
    #
    # Card fulfillment properties and methods
    #
    #===========================================================================

    public

    named_scope :needs_card, :conditions => [ '(user_type = ?) AND ((status & ?) <> 0 or status = ? or status = ?) AND ((status & ?) = 0)',
                                              ROLES[:member],
                                              StatusFlags[:needs_card],
                                              StatusFlags[:pending],
                                              StatusFlags[:pending_gift],
                                              StatusFlags[:expired] ]

    named_scope :expired, :conditions => ['(status & ?) = ?', StatusFlags[:expired], StatusFlags[:expired]]                                          
    named_scope :order_requested, :order => :date_card_requested
    named_scope :order_name, :order => :last_name
    named_scope :order_shipped, :order => :date_card_shipped
    named_scope :extra_cards_cardholders ,
                                :conditions => [ "user_type = ? AND ( partner_name REGEXP  '^[A-Za-z]' or partner_first_name REGEXP '^[A-Za-z]') AND (status = ? or status = ? )", ROLES[:member] ,StatusFlags[:default],StatusFlags[:needs_card]] 
    named_scope :extra_cards_members ,
                                :conditions => [ "user_type = ? AND (partner_name REGEXP  '^[A-Za-z]' or partner_first_name REGEXP '^[A-Za-z]' ) AND  status != ? AND status != ? ", ROLES[:member] ,StatusFlags[:default],StatusFlags[:needs_card]]

    def self.update_needs_card(ship_dates_by_user)
      User.update_all("status = #{User::StatusFlags[:default]}", { :id => ship_dates_by_user.keys})
      logger.info ( " dfdsf   #{ship_dates_by_user.values.to_s}")
      User.update(ship_dates_by_user.keys, ship_dates_by_user.values)
    end

    def pending!
      set_status(:pending, :clear => [:expired])
    end
    
    def pending?
      has_status?(:pending)
    end

    def pending_gift!
      set_status(:pending_gift, :clear => [:expired, :pending, :renewing, :needs_card])
    end

    def pending_gift?
      has_status?(:pending_gift)
    end

    def needs_card!
      set_status!(:needs_card)
    end

    def needs_card?
      has_status?(:needs_card)
    end

    def complete_friendly_status
      if user_type == ROLES[:newsletter_only]
        'Newsletter'
      elsif user_type == ROLES[:member]
        if status == StatusFlags[:default] 
          'Cardholder'
        elsif status == StatusFlags[:needs_card]  || status == StatusFlags[:pending] || status == StatusFlags[:pending_gift]        
          'Cardholder (No Renewal Reminder)'
        elsif status == StatusFlags[:expired]
          'Cardholder (Expired)'
        else
          'Member'
        end
      elsif user_type == ROLES[:administrator]
        'Administrator'
      end      
    end
    
    def friendly_status
      if user_type == ROLES[:newsletter_only]
        'Newsletter'
      elsif user_type == ROLES[:member]
        if status == StatusFlags[:default] || status == StatusFlags[:needs_card]  || status == StatusFlags[:pending] || status == StatusFlags[:pending_gift]        
          'Cardholder'
        else
          'Member'
        end
      elsif user_type == ROLES[:administrator]
        'Administrator'
      end
    end

    def user_cardholder?
      self.friendly_status == 'Cardholder' ? true :false
    end

    private

    def partner_name_format
      
      if  self.partner_first_name.blank? && self.partner_last_name.blank?
         return errors.add_to_base("Please provide a valid first name and last name for the extra card.")
      end
      
      if self.partner_name.blank?
        self.partner_name = "#{self.partner_first_name} #{self.partner_last_name}"
      end      
        errors.add_to_base("Please provide a valid first name and last name for the extra card.") if  card_num == 2 && !self.partner_name.match(/\A[A-Za-z]+\s[A-Za-z]+\z/)
    end

    #===========================================================================
    #
    # Card renewal properties and methods
    #
    #===========================================================================

    public

    def self.find_members_who_should_renew(reminder_intervals)
      User.all(
          #:select => "first_name, last_name, email, membership_expiration, status, email_format",
          :conditions => [
              "(user_type = ?) AND (status = ?) AND (DATEDIFF(membership_expiration, CURDATE()) IN (?))",
              ROLES[:member],
              StatusFlags[:default],
              reminder_intervals
          ])
    end

    def self.find_admin
      User.all(
          #:select => "first_name, last_name, email, membership_expiration, status, email_format",
          :conditions => [
              "(user_type = ?)",
              ROLES[:administrator]
          ])
      
    end
    
    def self.find_members_to_expire
        User.all(
            :conditions => [
                "(user_type = ?) AND (status = ?) AND (DATEDIFF(membership_expiration, CURDATE()) < 0)",
                ROLES[:member],
                StatusFlags[:default]
            ])
    end

    def self.find_members_who_expired
        User.all(
            :conditions => [
                "(user_type = ?) AND ((status & ?) = ?) AND (DATEDIFF(membership_expiration, CURDATE()) < 0)",
                ROLES[:member],
                StatusFlags[:expired],
                StatusFlags[:expired]
            ])
    end

    def self.find_gifts_starting_today
         User.all(
             :conditions => [
                "(user_type = ?) AND ((status & ?) = ?) AND gift_message_sent = 0 AND (DATEDIFF(gift_start_date, CURDATE()) <= 0)",
                ROLES[:member],
                StatusFlags[:pending_gift],
                StatusFlags[:pending_gift]
            ])
    end

    def renewing
      set_status(:renewing)
    end

    def renewing?
      has_status?(:renewing)
    end

    def renew
        set_status(:needs_card, :clear => [:expired, :pending, :renewing, :pending_gift])
    end

    def expire!
        set_status!(:expired)
    end

    def expired?
      has_status?(:expired)
    end



    #===========================================================================
    #
    # Promo Code
    #
    #===========================================================================

    attr_accessor :promo_code_code

    def promo_code_code= code
      @promo_code_code = code
      self.promo_code = PromoCode.find_by_code(@promo_code_code)
    end

    def promo_code_must_be_valid
      if !@promo_code_code.blank? and self.promo_code.nil?
        errors.add(:promo_code, I18n.translate('users.create.invalid_promo_code'))
      end
      if self.promo_code.present? and self.promo_code.expired?
        errors.add(:promo_code, I18n.translate('users.create.expired_promo_code'))
      end
    end

    #===========================================================================
    #
    # Confirm email
    #
    #===========================================================================

    attr_accessor :confirm_email

end
