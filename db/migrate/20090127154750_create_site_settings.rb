class CreateSiteSettings < ActiveRecord::Migration
    def self.up
        create_table :site_settings do |t|
            t.float   :membership_cost
            t.integer :membership_length
            t.integer :signup_discount_referrals
            t.float   :signup_discount_amount
        end

        SiteSettings.create!(
            :membership_cost => '65.00',
            :membership_length => 12,
            :signup_discount_referrals => 5,
            :signup_discount_amount => '0.00'
        )
    end

    def self.down
        drop_table :site_settings
    end
end
