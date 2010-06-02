require 'RMagick'

class UsersController < ApplicationController
  include ApplicationHelper
  include BillingHelper
  include LocationHelper

  protect_from_forgery :except => :verify_payment

  before_filter :login_required, :only => [:edit, :update, :view, :show]
  requires_role :administrator, :only => [:pending_cards, :index, :send_news_alert]

  def new
    @user = User.new
    @user.role = :member
    @user.email_format = User::EmailFormat[:html]
  end


  def create
    from_admin = logged_in? && current_user.administrator?
    site_settings = SiteSettings.get        
    logout_keeping_session! unless from_admin

    params[:user][:category_ids] ||= []
    @user = User.initialize_user(params[:user].merge(:validate_gift_form => false), site_settings.membership_length)
    success = @user.valid?

    # Don't check legal and billing if this is
    # an admin creating the account
    unless from_admin
      # Legal accepted?
      if params[:accepted_agreement].nil?
        @user.errors.add_to_base(t('users.create.legal_not_accepted'))
        success = false
      end

      # Referrals valid?
      result = Referral.check_referrals(@user, params[:referrals] || [])   
      success = success && result
    end # unless from_admin

    success = success && @user.save(false)

    if success
      Referral.save_referrals(@user, params[:referrals] || [])
      if params[:bypass_billing]
        @user.member_since = Time.zone.now
        @user.signed_up!
        UserMailer.deliver_signup_notification(@user)
        redirect_to user_path(@user)
      else
        params[:encrypted] = paypal_encrypted(
          @user.card_num,
          site_settings.membership_cost - site_settings.signup_discount_amount,
          params[:billing_use_shipping] ? params[:user][:shipping_location] : nil
        )
         render :template => '/users/checkout_redirect',:layout => false
        #render :template => '/users/paypal_form', :layout => false
        #redirect_to paypal_url(@signup_cost, item_name, params[:billing_use_shipping] ? params[:user][:shipping_location]:nil, return_from_paypal_url , Rails.root + '/verify/' + @user.activation_code)
      end
    else
      if(@user.errors.on(:email) == 'is already in use')
        flash.now[:error]  = 'You already have an account with Shop the Block. In order to renew your Shop the Block card, please click <a href=\'login\'>Here</a> now.'
        @user.errors.clear
      else
      
        flash.now[:error]  = t('users.create.failed')
      end
      
      @user.card_num = 0 if @user.card_num == 1
      render :action => 'new'
    end

  end


  def edit
    user_id = params[:id]
    if validate_user(user_id)
      if current_user.administrator?
        @user = User.find(user_id)
        
        @site_settings = SiteSettings.get if @user.administrator?
      else
        @user = current_user
      end
    end
  end


  def update
    params[:user][:category_ids] ||= []
    @user = User.find(params[:id])
    @site_settings = nil
    success = true

    if validate_user(@user.id)
      # fix bug S284
      @user.update_extra_card_info params[:user]      
      @user.attributes = params[:user]
      if current_user.administrator? && params[:user][:membership_expiration]
        @user.membership_expiration = params[:user][:membership_expiration]
      end
      
      if(@user.expired?)
          if(@user.membership_expiration > Time.now)
            @user.pending!
          end
      end
      
      success = success && @user.valid?
      
            
      if @user.administrator? && params[:site_settings]
        @site_settings = SiteSettings.get
        @site_settings.attributes = params[:site_settings]
        success = success && @site_settings.valid?
      end

      update = false
      if current_user.administrator?
         update =   @user.save(false) && (@site_settings.nil? || @site_settings.save)         
      else
        update = success && @user.save && (@site_settings.nil? || @site_settings.save)
      end

      if update
        flash[:notice] = t('users.update.success')
        redirect_to user_path(@user)
      else
        flash.now[:error]  = t('users.update.failed')
        render :action => 'edit'
      end

    end
  end

  def view
    @user = current_user

    if(current_user.expired?)
      redirect_to renew_url
    end
    
  end

  def show
    @user = User.find(params[:id])

    render(:action => 'view') if validate_user(@user.id)
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def temp_card
    @user =  current_user.nil? ? User.find(params[:id]) : current_user
    render :template => 'users/temp_card', :layout => false
  end

  def temp_card_image
    @user =  current_user.nil? ? User.find(params[:id]) : current_user

    path = File::join(RAILS_ROOT, 'app', 'views', 'users', 'tempcard.png')
    image = Magick::ImageList::new(path)

    text = Magick::Draw.new
    text.font_family = "arial"
    text.pointsize = 40
    text.gravity = Magick::NorthWestGravity
    text.fill = "black"
    if params[:partner] && @user.partner_name?
      text.annotate(image, 0, 0, 350, 240, @user.partner_name)
    else
      text.annotate(image, 0, 0, 350, 240, "#{@user.first_name} #{@user.last_name}")
    end
    text.pointsize = 30
    text.gravity = Magick::NorthWestGravity
    text.annotate(image, 0, 0, 350, 290, @user.member_id.to_s)
    text.gravity = Magick::NorthWestGravity
    text.annotate(image, 0, 0, 350, 340, "Exp. #{@user.membership_expiration.strftime("%d/%m/%y")}")

    send_data(image[0].to_blob, :type => image[0].mime_type, :disposition => 'inline', :filename => 'tempcard')
  end

  def lost_card
    @user = User.find_by_activation_code(params[:code])
    if @user
      self.current_user = @user
      @user.needs_card! unless @user.pending?
      UserMailer.deliver_lost_card(@user)
    else
      flash[:error] = t("users.lost_card.fail_not_found")
      redirect_to welcome_path
    end
  end

  def pending_cards
    @mode = params[:mode]
    logger.info   "  Pending cards    #{params[:mode]}"
    @mode = @mode.blank? ? :view : @mode.to_sym

    # Get list of pending users. In update case
    # we want to do this after we've done the update
    @pending_users = User.needs_card.all(:order => sort_value) unless @mode == :update

    case @mode
    when :update
      update_pending_cards
      @mode = :view
      @pending_users = User.needs_card.all(:order => sort_value)
    when :print
      render :action => 'pending_cards', :layout => 'print'
      return
    when :export
      render_export_pending_cards
      return
    when :view
      respond_to do |format|
        format.html
        format.js { render :partial => "pending_table", :layout => false }
      end
    end
  end

  def index
    @users = User.non_merchant.non_admin.all(:order => sort_value)
    @grouped_users = @users.group_by(&:friendly_status)    
    @count_extracard_cardholders = User.extra_cards_cardholders.count
    @count_extracard_members = User.extra_cards_members.count
    
    respond_to do |format|
      format.html
      format.js { render :partial => "members_table", :layout => false }
    end
  end


  def renew
    @user = current_user
    @site_settings = SiteSettings.get
    #@renew_length = ( Time.zone.now <= @user.membership_expiration ) ? @site_settings.early_renewal_length : @site_settings.renewal_length
    
    @renewal_date = ( Time.zone.now <= @user.membership_expiration.advance(:days => 1) ) ? @user.membership_expiration.advance(:months => @site_settings.early_renewal_length) : Time.zone.now.advance(:months => @site_settings.renewal_length)
        
    if @user.nil?
      @user_id = params[:user_id]
      @user = User.find_by_id(@user_id)
      
      if @user.nil?
        @user_id = params[:user][:user_id]
        @user = User.find_by_id(@user_id)
      end
    end
    if request.method == :post
      success = true
      
      if params[:accepted_agreement].nil?
        flash[:error] = t('users.create.legal_not_accepted')
        #@user.errors.add_to_base(t('users.create.legal_not_accepted'))
        success = false
      end
      
      @user.attributes = params[:user]
      @user.renewing
      @user.date_card_requested = Time.zone.now    
      @user.date_card_shipped = nil
      if @user.save
        params[:encrypted] = paypal_encrypted(
          @user.card_num,
          ( Time.zone.now <= @user.membership_expiration ) ? SiteSettings.get.early_renewal_cost : SiteSettings.get.renewal_cost,
          params[:billing_use_shipping] ? params[:user][:shipping_location] : nil,
          true
        )
      #  render :template => '/users/paypal_form', :layout => false

        if(success)
          render :template => '/users/checkout_redirect',:layout => false
        end
      else
        @user.card_num = 0 if @user.card_num == 1
      end
    end

  end

  def renew_membership

    @user = User.find_by_activation_code(params[:code])

    if @user == nil
      flash[:error] = t('users.return_from_paypal.fail_not_found')
      redirect_to :welcome
    else
      self.current_user = @user
      redirect_to :action => "renew"
    end
    
  end
  
  def forgot_password

    if request.method == :post

      if params[:email].nil?
        flash[:error] = t('users.forgot_password.no_email')
      else
        user = User.find_by_email(params[:email])
        if user.nil?
          flash[:error] = t('users.forgot_password.no_match')
        else
          user.password_reset_code = user.encrypt("#{user.full_name}#{user.crypted_password}")
          if user.save && UserMailer.deliver_forgot_password(user)
            flash[:notice] = t('users.forgot_password.success')
            redirect_to root_path
          else
            flash[:error] = t('users.forgot_password.failed')
          end
        end
      end

    end

  end

  def reset_password

    @reset_code = params[:code]
    @user = User.find_by_password_reset_code(@reset_code) if @reset_code

    if request.method == :post

      if params[:email] != @user.email
        flash[:error] = t('users.reset_password.email_mismatch')
      elsif params[:user].nil? || params[:user][:password].blank?
        flash[:error] = t('users.reset_password.no_password')
      elsif @user.update_attributes(params[:user])
        flash[:notice] = t('users.reset_password.success')
        redirect_to login_path
      else
        # View will display user errors
      end

    end

  end

  def send_news_alert
    @members = User.active_members
    @non_members = User.non_member_newsletter_recipients
    @categories = Category.all(:order => 'categories.name ASC')

    if request.method == :post
      @subject = params[:subject]
      @message = params[:message]
      @news_alert = NewsAlert.new(:users => params[:users], 
                                  :recipient_method => params[:recipients], 
                                  :categories => params[:categories])
      if @subject.blank?
        flash[:error] = t('users.send_news_alert.no_subject')
      elsif @message.blank?
        flash[:error] = t('users.send_news_alert.no_message')
      else
        if @news_alert.save
          succeeded = 0
          failed = 0

          @news_alert.recipients.each do |user|
            begin
              UserMailer.deliver_site_news(user, @subject, @message)
              succeeded += 1
            rescue Exception => e
              logger.error("Failed to send news alert for #{user.email}: #{e}")
              failed += 1
            end
          end

          flash[:notice] = t('users.send_news_alert.success', :count => succeeded) if succeeded > 0
          flash[:error] = t('users.send_news_alert.failed', :count => failed) if failed > 0
          redirect_to account_path
        else
          flash[:error] = t('users.send_news_alert.error_saving')
        end
      end
    else
      @news_alert = NewsAlert.new(:users => [], :categories => [])
    end
  end

  # Handles administrator request to manage list of newsletter
  # recipients who aren't members
  def edit_newsletter_recipients    

    @recipients = User.find( :all,  :conditions => { :user_type => User::ROLES[:newsletter_only] },  :select => "id, email,user_type,status",  :order => "email ASC" )
    @members   =  User.find( :all,  :conditions => { :user_type => User::ROLES[:member] ,:newsletter => User::NewsletterPreference[:weekly]},  :select => "id, email,partner_email,user_type,status,partner_newsletter",  :order => "email ASC" )
    
    if request.method == :post

      if params[:add_recipients]
        emails = params[:add_recipients].downcase.split(' ')
        add_newsletter_recipients(emails)
      elsif params[:remove_recipients]
        remove_newsletter_recipients(params[:remove_recipients],params[:remove_partner_recipients])
      end
      
      if params[:subscribe]
        redirect_to news_items_path # this is where the user is redirected to after subscribing
      else
        if flash[:error].blank?
          redirect_to account_path if flash[:error].blank?
        else
          flash.discard   # Make sure flash gets nuked after this request
        end
      end
    end
  end

  def unsubscribe
    if !User.exists?(:activation_code => params[:code])
      flash[:error] = t('users.unsubscribe.fail_invalid_id')
    else
      user = User.find_by_activation_code params[:code]
      if user.user_type != User::ROLES[:newsletter_only]
        flash[:error] = t('users.unsubscribe.fail_member')
      elsif user.destroy
        flash[:message] = t('users.unsubscribe.success')
      else
        flash[:error] = t('users.unsubscribe.fail_error')
      end
    end
    redirect_to :welcome
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = t('users.destroy.success')
    else
      flash[:error] = t('users.destroy.fail_error')
    end
    redirect_to :back
  end

  def verify_payment
    logger.info "PAYMENT_STATUS: " + params[:payment_status].to_s
    logger.info "RECEIVER_EMAIL: " + params[:receiver_email].to_s
    logger.info "ACTIVATION_CODE: " + params[:code].to_s
   @user = User.find_by_activation_code(params[:code])
    if !@user
        logger.info "USER WAS NOT FOUND FOR IPN RESPONSE"
        head :user_not_found
        return
    end
    # if user dian't retrun from paypal we got verify and we should check  member_since
    sign_up_complete @user , params[:gift]

    if params[:payment_status] == "Completed" && params[:receiver_email] == PAYPAL_EMAIL
          logger.info "**********************COMPLETED TRANSACTION**************************"
          if @user.pending? || @user.renewing?
                if  params[:gift]  == 'true'
                  @user.signed_up_gift!
                else
                  @user.signed_up!
                end
          end
    else 
          logger.info "INVALID TRANSACTION"
    end

    head :ok
  end

  def sign_up_complete user ,gift = false,renew = false
    # Make sure we don't process anything twice      
      return   if user.member_since && user.renewing? == false
      @site_settings = SiteSettings.get
    
      @renewal_date = ( Time.zone.now <= user.membership_expiration ) ? user.membership_expiration.advance(:months => @site_settings.early_renewal_length) : Time.zone.now.advance(:months => @site_settings.renewal_length) if user.renewing?
    
     #renewal_length = ( Time.zone.now <= @user.membership_expiration ) ? SiteSettings.get.early_renewal_length : SiteSettings.get.renewal_length    
     user.membership_expiration = @renewal_date  if user.renewing?
     user.update_attribute(:member_since,Time.zone.now) if user.member_since == nil
     end_date =  user.gift_start_date || Time.zone.now
     user.membership_expiration =  end_date.advance(:months => SiteSettings.get.membership_length) if  user.membership_expiration.nil?
     user.renew
     user.update_attribute(:membership_expiration,user.membership_expiration )
     
     
      if gift == true
         UserMailer.deliver_gift_receipt(user)
         UserMailer.deliver_gift_purchased(user) if user.gift_start_date <= Date.today
      else
        if renew == true
          UserMailer.deliver_renew_notification(user)
          Referral.send_emails(user)
        else
          UserMailer.deliver_signup_notification(user)
          Referral.send_emails(user)
        end
      end

  end

  def return_from_paypal
    @user = User.find_by_activation_code(params[:code])

    if @user == nil
      flash[:error] = t('users.return_from_paypal.fail_not_found')
      redirect_to :welcome
    end

    #klm
    #if(@user.is_a_renewal == true)
    #  redirect_to :return_from_paypal_renewal
    #end
    
    self.current_user = @user
    if @user.neighbourhood_location
        set_location_to(@user.neighbourhood_location)
        save_location
    end

    sign_up_complete  @user
   
    flash.now[:notice] = params[:renew] ? t('users.renew.success'):t('users.create.success')
    render :template => 'users/confirmation'
    
  end

  def return_from_paypal_renewal
    @user = User.find_by_activation_code(params[:code])

    if @user == nil
      flash[:error] = t('users.return_from_paypal.fail_not_found')
      redirect_to :welcome
    end

    self.current_user = @user
    
    if @user.neighbourhood_location
        set_location_to(@user.neighbourhood_location)
        save_location
    end

    sign_up_complete  @user, false, true
   
    flash.now[:notice] = t('users.renew.success')
    render :template => 'users/renewal_confirmation'
    
  end

  def send_signup_email
    @user = User.find(params[:id])
    if @user
       UserMailer.deliver_signup_notification(@user)
       flash[:notice]  = t('users.create.success')
    end
    redirect_to user_path(@user)
  end

  def expired
    #@users = User.find_members_who_should_renew([30, 14,7])
    @users = User.find_members_who_expired
    @grouped_users = @users.group_by(&:friendly_status)    
    @count_extracard_cardholders = User.extra_cards_cardholders.count
    @count_extracard_members = User.extra_cards_members.count
    
    respond_to do |format|
      format.html
      format.js { render :partial => "members_table", :layout => false }
    end
     
  end

  
  private # Internal Helper Methods

  def sort_value
    case params[:sort]
     when "id"                          then "id"
     when "name"                        then "last_name"
     when "card_num"                    then "card_num"
     when "promo_code_id"               then "promo_code_id"
     when "email"                       then "email"
     when "status"                      then "status"
     when "heard_about_from"            then "heard_about_from"
     when "date_card_requested"         then "created_at"
     when "date_card_shipped"           then "date_card_shipped"
     when "name_reverse"                then "last_name DESC"
     when "id_reverse"                  then "id DESC"
     when "card_num_reverse"            then "card_num DESC"
     when "promo_code_id_reverse"       then "promo_code_id DESC"
     when "email_reverse"               then "email DESC"
     when "status_reverse"              then "status DESC"
     when "heard_about_from_reverse"    then "heard_about_from DESC"
     when "date_card_requested_reverse" then "created_at DESC"
     when "date_card_shipped_reverse"   then "date_card_shipped DESC"
     else                                    'users.created_at DESC'
    end
  end

  def update_pending_cards
    params[:ship_dates].delete_if do |user_id, ship_date|
      ship_date["date_card_shipped"].empty?
    end
    User.update_needs_card(params[:ship_dates] || {})
  end

  def render_export_pending_cards
  end

  # Adds the list of emails as "newsletter_only" user records.
  # If a user is an existing user that is not newsletter_only then
  # an error is added.
  def add_newsletter_recipients(email_list)

    failed_emails = []
    skipped_emails = []
    enabled_members = []
    added_count = 0

    # Get a list of existing users
    existing_users = User.find(
      :all,
      :select => 'id, email, user_type, newsletter',
      :conditions => ["email IN (?)", email_list]
    )

    existing_users.each do |u|
      email_list.delete(u.email.downcase)

      if (u.role == :member)
        if (u.newsletter == User::NewsletterPreference[:never])
          # For members, make sure newsletter is enabled
          u.update_attribute('newsletter',User::NewsletterPreference[:weekly])
          enabled_members << t('users.edit_newsletter_recipients.added_email', :email => u.email)
          added_count += 1
        else
          skipped_emails << t('users.edit_newsletter_recipients.skipped_member', :email => u.email)
        end
      else
        skipped_emails << t('users.edit_newsletter_recipients.skipped_role', :email => u.email, :role => u.role.to_s)
      end
    end

    # Add remaining email addresses
    email_list.each do |email|
      u = User.new(:email => email)
      u.role = :newsletter_only
      u.password = Array.new(20){|i| rand(10) }.join  # Random 20 char password
      u.password_confirmation = u.password
      u.newsletter = User::NewsletterPreference[:weekly]
      u.email_format = User::EmailFormat[:html]
      u.shipping_address = "newsletter_only"
      u.shipping_address2 = "newsletter_only"
      u.shipping_city = "newsletter_only"
      u.shipping_postalcode = "newsletter_only"
      u.shipping_province = "newsletter_only"
      if u.save
        added_count += 1
      else
        failed_emails << t('users.edit_newsletter_recipients.failed_email', :email => email, :error => u.errors.full_messages[0])
      end
    end

    flash[:notice] = ''

    if params[:subscribe]
      if added_count == 1
        flash[:notice] = t('users.edit_newsletter_recipients.subscribe_success')
      else
        flash[:error] = t('users.edit_newsletter_recipients.subscribe_fail_exists') unless skipped_emails.blank? # account is already signed up
        flash[:error] = t('users.edit_newsletter_recipients.subscribe_fail_email') unless failed_emails.blank? # email is invalid
      end
      flash.delete(:notice) if flash[:notice].blank?
      flash.delete(:error) if flash[:error].blank?
      return
    else
      flash[:notice] += t('users.edit_newsletter_recipients.succeeded_emails', :count => added_count) if added_count > 0
      flash[:notice] += t('users.edit_newsletter_recipients.member_emails', :emails => enabled_members.join) unless enabled_members.blank?
      flash[:notice] += t('users.edit_newsletter_recipients.skipped_emails', :emails => skipped_emails.join) unless skipped_emails.blank?
      flash.delete(:notice) if flash[:notice].blank?
      flash[:error] = t('users.edit_newsletter_recipients.failed_emails', :emails => failed_emails.join) unless failed_emails.blank?
    end
  end

  def remove_newsletter_recipients(userid_list , partner_emails_list )

    # remove partner extra-card from subsribers
     unless partner_emails_list.nil?
          remove_newsletter_partner_recipients(partner_emails_list )
     end

         existing_users = User.find(
        :all,
        :select => 'id, user_type, newsletter',
        :conditions => [" id IN (?)", userid_list]
      )

       existing_users.each do |u|
          if (u.role == :member)
            # For members, make sure newsletter is disabled           
            u.update_attribute('newsletter',User::NewsletterPreference[:never])
            end
          end
     
    # Assumes these are newsletter-only users and therefore no relationships  
    User.delete_all({
        :user_type => User::ROLES[:newsletter_only],
        :id => userid_list
      })
    count =  partner_emails_list.nil? ? userid_list.length : userid_list.length + partner_emails_list.length
    flash[:notice] = t('users.edit_newsletter_recipients.removed_emails', :count => count)
  end

  def  remove_newsletter_partner_recipients(partner_emails_list )

     existing_partners = User.find(
        :all,
        :select => 'id,partner_newsletter',
        :conditions => [" partner_email IN (?)", partner_emails_list ]
      )

      existing_partners.each do | partner|
            # For partner of members, make sure newsletter is disabled
            partner.update_attribute('partner_newsletter',User::NewsletterPreference[:never])
      end
  end

  
end
