class Referral < ActiveRecord::Base
  belongs_to :referrer, :class_name => "User", :foreign_key => "referrer_id"


  def self.check_referrals(user, referrals)
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
            user.errors.add_to_base(I18n.translate('users.create.referral_invalid', :email => referral))
            referrals[i] = "!" + referral
            success = false
          elsif user.email.casecmp(referral) == 0
            user.errors.add_to_base(I18n.translate('users.create.referral_self'))
            referrals[i] = "!" + referral
            success = false
          elsif (!existing_members.select{ |u| u.email.casecmp(referral) == 0 }.empty?)
            user.errors.add_to_base(I18n.translate('users.create.referral_exists', :email => referral))
            referrals[i] = "!" + referral
            success = false
          end
        end
      end
    end

    return success
  end
  
  def self.save_referrals(user, emails)
    return unless user && emails.any?
    emails.each do |email|
      Referral.create(:referrer_id => user.id, :referral_email => email) unless email.blank?
    end
  end
  
  def self.send_emails(user)
    referrals = Referral.find_all_by_referrer_id(user.id)
    emails = referrals.map {|referral| referral.referral_email}
    UserMailer.deliver_referral_mail(user, emails) if emails.any?
  end
end
