class AddSeparatePartnerFirstAndLastNamesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_first_name, :string
    add_column :users, :partner_last_name, :string
  end

  def self.down
    remove_column :users, :partner_first_name
    remove_column :users, :partner_last_name
  end
end
