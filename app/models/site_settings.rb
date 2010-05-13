class SiteSettings < ActiveRecord::Base

    validates_presence_of(
        :membership_cost,
        :membership_length,
        :signup_discount_amount,
        :signup_discount_referrals
    )
    validates_format_of(
        :membership_cost,
        :with => /\A\d+(\.\d{1,2})?\Z/,
        :message => 'is not a valid amount'
    )
    validates_numericality_of(
        :membership_length,
        :greater_than => 0,
        :only_integer => true
    )
    validates_format_of(
        :signup_discount_amount,
        :with => /\A\d+(\.\d{1,2})?\Z/,
        :message => 'is not a valid amount'
    )
    validates_numericality_of(
        :signup_discount_referrals,
        :greater_than => 0,
        :less_than_or_equal_to => 10,
        :only_integer => true,
        :message => 'must be between 1 and 10'
    )

    def self.get
        SiteSettings.first
    end

end
