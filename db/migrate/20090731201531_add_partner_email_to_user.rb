class AddPartnerEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_email, :string
  end

  def self.down
    remove_column :users, :partner_email
  end
end
