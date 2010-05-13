class UserMailer < ActionMailer::Base
  include ApplicationHelper

  def signup_notification(user)
    setup_email(user) do
      @subject    = t('user_mailer.signup_notification.subject')
    end
  end
  
  def activation(user)
    setup_email(user) do
      @subject    = t('user_mailer.activation.subject')
    end
  end

  def lost_card(user, body_fields={})
    setup_email(user) do
      @subject    = t('user_mailer.lost_card.subject')
    end
  end

  def daily_status(user, body_fields={})
    setup_email(user) do
      @subject        = t('user_mailer.daily_status.subject')
      @body.merge!    body_fields
    end
  end

  def account_expired(user)
    setup_email(user) do
      @subject        = t('user_mailer.account_expired.subject')
    end
  end

  def renewal_reminder(user)
    setup_email(user) do
      @subject        = t('user_mailer.renewal_reminder.subject')
    end
  end

  def forgot_password(user)
    setup_email(user) do
      @subject        = t('user_mailer.forgot_password.subject')
    end
  end

  def site_news(user, headline, message)
    setup_email(user) do
      @subject        = "Best of the Block: #{headline}"
      @body[:headline] = headline
      @body[:message] = message
    end
  end

  def newsletter(newsletter, user)
    setup_email(user) do
      @subject = "Shop The Block - #{newsletter.title} - Volume #{newsletter.volume}, Issue #{newsletter.issue}"
      @body[:newsletter] = newsletter
    end
  end

  def referral_mail(user,referrers)
    setup_email(user,true) do
      @bcc = referrers
      @subject = t('user_mailer.referrer_mail.subject')
      @body[:referrer_name] = user.name
    end
  end

  def gift_receipt(user)    
    amount = SiteSettings.get.membership_cost
    amount += 10 if user.card_num > 1 #PARTNER_MEMBERSHIP_COST 

    setup_email(user,true) do
      @recipients = "#{user.gift_giver_name} <#{user.gift_giver_email}>"
      @subject = "You successfully purchased a Shop the Block card for #{user.name}!"
      @body[:user] = user
      @body[:amount] = amount
    end
        
  end
  
  def gift_purchased(user)
    setup_email(user) do
      @subject = "#{user.gift_giver_name} has purchased a Shop the Block card for you!"
      @body[:code] = user.activation_code
      @body[:user] = user
    end
    user.update_attribute(:gift_message_sent, true)
  end
  
  def pick_layout(opts)
    if opts[:file].end_with?('_html')
      'layouts/email_html'
    elsif opts[:file].end_with?('_text')
      'layouts/email_text'
    else
      false
    end
  end

  protected

  def setup_email(user, no_recipient=false, &block)
    @recipients     = "#{user.full_name} <#{user.email}>" unless no_recipient
    @from           = "#{t('site_name')} <lauren@shoptheblock.ca>"
    @subject        = ""
    @sent_on        = Time.now
    @body[:user]    = user

    block.call if block_given?
        
    case user.email_format
    when User::EmailFormat[:html] then

      @content_type = "multipart/alternative"

      part "text/plain" do |p|
        p.body = render_message(@template + '_text', @body)
      end

      part "text/html" do |p|
        p.body = render_message(@template + '_html', @body)
      end

      else

      @template += '_text'

    end
  end

  def t(key, *options)
    I18n.translate(key, options)
  end

  helper_method :link_to_site

  def link_to_site(text=nil)
    url = root_url.chomp('/')
    "<a href='#{url}'>#{ text || url.gsub(/https?:\/\//, '') }</a>"
  end

end
