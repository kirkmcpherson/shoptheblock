class CreateReferrals < ActiveRecord::Migration
  def self.up
    create_table :referrals do |t|
      t.references :referrer
      t.string :referral_email
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :referrals
  end
end
