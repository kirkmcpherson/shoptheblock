class SessionsController < ApplicationController
  include LocationHelper

  def new
  end


  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      set_location_to(user.neighbourhood_location)
      save_location()
      if User.expired?(params[:email])
        flash[:error] = t('session.expired')
        redirect_to :controller => 'users', :action => 'renew'
      elsif(!user.membership_expiration.nil? && ( (Time.now + 14.days) >= user.membership_expiration) )
        flash[:error] = t('session.expires_soon')
        redirect_to :controller => 'users', :action => 'renew'      
      else
        redirect_back_or_default('/')
        flash[:notice] = t('session.logged_in')
      end
    elsif User.expired?(params[:email])
      self.current_user = User.find_by_email(params[:email])
      flash[:error] = t('session.expired')
      redirect_to :controller => 'users', :action => 'renew'      
    elsif User.pending?(params[:email])
      self.current_user = User.find_by_email(params[:email])
      flash[:error] = t('session.pending')
      redirect_to :signup
    else
      note_failed_signin
      @email       = params[:email]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = t('session.logged_out')
    redirect_back_or_default('/')
  end

  protected

  # Track failed login attempts
  def note_failed_signin
    flash.now[:error]= t('session.login_failed', :email => params[:email])
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
