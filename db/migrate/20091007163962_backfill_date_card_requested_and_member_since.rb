class BackfillDateCardRequestedAndMemberSince < ActiveRecord::Migration
  def self.up
    
    User.all.each do |user|      
       # only cardholders
       unless user.user_type == User::ROLES[:member]
         next
       end
     
       if !user.membership_expiration.nil?
           new_member_since = new_date_card_requested  = user.membership_expiration.last_year()

           # sometimes  user.membership_expiration.last_year() is bigger than user.date_card_requested
           if !user.date_card_shipped.nil? && user.date_card_shipped <  new_date_card_requested
             new_date_card_requested = user.date_card_shipped
           end

       elsif !user.date_card_shipped.nil?
            new_member_since = new_date_card_requested  = user.date_card_shipped
       end

       user.update_attribute  :date_card_requested ,new_date_card_requested  if user.date_card_requested.nil?
       user.update_attribute  :member_since , new_member_since  if user.member_since.nil?
    
       
       say "Updated #{user.first_name}'s   #{user.date_card_requested.to_s}."

     end

  end

  def self.down
  end
end
