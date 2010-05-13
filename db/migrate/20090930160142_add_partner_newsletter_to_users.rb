class AddPartnerNewsletterToUsers < ActiveRecord::Migration
  def self.up
   add_column :users,:partner_newsletter, :tinyint,:default => User::NewsletterPreference[:weekly]
  end

  def self.down
    remove_column :users,  :partner_newsletter
  end
end
