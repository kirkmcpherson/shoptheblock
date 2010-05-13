class ChangeUserMembersinceDateDatetime < ActiveRecord::Migration
 def self.up
       change_column :users, :member_since, :datetime

    User.all.each do |user|
       # only cardholders
       unless user.user_type == User::ROLES[:member]
         next
       end


       if !user.membership_expiration.nil?
           new_member_since = new_date_card_requested = user.membership_expiration.last_year()

           # sometimes user.membership_expiration.last_year() is bigger than user.date_card_requested
           if !user.date_card_shipped.nil? && user.date_card_shipped < new_date_card_requested
             new_date_card_requested = user.date_card_shipped
           end

       elsif !user.date_card_shipped.nil?
            new_member_since = new_date_card_requested = user.date_card_shipped
       end
       
        #if !user.member_since.nil? && user.member_since > new_member_since
         # user.update_attribute :member_since , new_member_since
        # say " use #{user.first_name}"
        if !user.member_since.nil? && user.member_since < user.date_card_requested
           user.update_attribute :member_since , user.date_card_requested
           say " use #{user.first_name}"
        end
       user.update_attribute :member_since , user.date_card_requested if user.member_since.nil? && !user.date_card_requested.nil?
      end

  end

  def self.down
       change_column :users, :member_since, :date
  end
end
