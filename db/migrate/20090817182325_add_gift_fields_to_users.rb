class AddGiftFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gift_giver_first_name, :string, :limit => 50, :null => true
    add_column :users, :gift_giver_last_name, :string, :limit => 50, :null => true
    add_column :users, :gift_giver_email, :string, :limit => 100, :null => true    
    add_column :users, :gift_start_date, :date, :null => true
  end

  def self.down
    remove_column :users, :gift_giver_first_name
    remove_column :users, :gift_giver_last_name
    remove_column :users, :gift_giver_email
    remove_column :users, :gift_start_date
  end
end
