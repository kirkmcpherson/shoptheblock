class GiftsController < ApplicationController
  
  def new
    @user = User.new
  end
  
  def create
    site_settings = SiteSettings.get
        
    logout_keeping_session!

    params[:user][:category_ids] ||= []

    @user = User.initialize_user(params[:user].merge(:validate_gift_form => true), site_settings.membership_length)
    # set user default format as html format
    @user.email_format = User::EmailFormat[:html]
    @user.crypted_password = ''
    success = @user.valid? 
    
    success = @user.valid_gift_fields? && success

    if success && @user.save(false)

      params[:encrypted] = paypal_encrypted(
        @user.card_num,
        params[:billing_use_shipping] ? params[:user][:gift_location] : nil,
        false,
        true
      )
      #render :template => '/users/paypal_form', :layout => false
       render :template => '/users/checkout_redirect',:layout => false
    else
      flash.now[:error]  = t('users.create.failed')
      @user.card_num = 0 if @user.card_num == 1
      render :action => 'new'
    end

  end


  def edit
    @user = User.find_by_activation_code(params[:id])
    unless @user && @user.pending_gift?
      #flash[:error] = t()
      redirect_to welcome_path
    end
    @site_settings = SiteSettings.get
  end


  def update
    @user = User.find_by_activation_code(params[:id])
    unless @user && @user.pending_gift?
      #flash[:error] = t()
      redirect_to welcome_path
      return
    end
    @site_settings = SiteSettings.get
    
    params[:user][:category_ids] ||= []
    @user = User.initialize_user(params[:user].merge(:validate_gift_form => false), @site_settings.membership_length)
    success = @user.valid?

    # Legal accepted?
    if params[:accepted_agreement].nil?
      @user.errors.add_to_base(t('users.create.legal_not_accepted'))
      success = false
    end

    # Referrals valid?
    result = Referral.check_referrals(@user, params[:referrals] || [])   
    success = success && result

    if success
      Referral.save_referrals(@user, params[:referrals] || [])
      Referral.send_emails(@user)
      @user.signed_up!

      self.current_user = @user
      if @user.neighbourhood_location
        set_location_to(@user.neighbourhood_location)
        save_location
      end

      render :template => 'gifts/confirmation'
    else
      flash.now[:error]  = t('users.create.failed')
      render :action => 'edit'
    end        
  end
  

  def return_from_paypal_gift
    @user = User.find_by_activation_code(params[:code])

    unless @user
      flash[:error] = t('users.return_from_paypal.fail_not_found')
      redirect_to welcome_path
      return
    end
    
   
      date = @user.gift_start_date || Time.zone.now
      date = date.advance(:months => SiteSettings.get.membership_length)
      @user.update_attribute(:member_since,Time.zone.now) if @user.member_since == nil
      @user.update_attribute(:membership_expiration,date)  if  @user.membership_expiration.nil?

      UserMailer.deliver_gift_receipt(@user)
      UserMailer.deliver_gift_purchased(@user) if @user.gift_start_date <= Date.today  
  end

end