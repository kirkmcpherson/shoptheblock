class AddExpiryFieldToNewsletters < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :expired, :boolean, :default_value => false
    Newsletter.all.each { |newsletter| newsletter.update_attribute(:expired, false) }
  end

  def self.down
    remove_column :newsletters, :expired
  end
end
