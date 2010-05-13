class SplitPartnerName < ActiveRecord::Migration
  def self.up


    User.all.each do |user|
       # only cardholders
       unless user.user_type == User::ROLES[:member]
         next
       end

      if user.partner_name.nil?
         next
      end

      if user.partner_first_name.blank? || user.partner_last_name.blank?
        names = user.partner_name.split

       user.update_attribute  :partner_first_name ,names[0]  if !names[0].nil? &&  user.partner_first_name.blank?
       user.update_attribute  :partner_last_name , names[1]   if !names[1].nil? && user.partner_last_name.blank?

       say "Updated #{user.partner_first_name}'s   #{user.partner_name}."
     end

    end
  end

  def self.down
  end
end
