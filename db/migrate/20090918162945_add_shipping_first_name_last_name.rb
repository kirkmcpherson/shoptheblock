class AddShippingFirstNameLastName < ActiveRecord::Migration
  def self.up
    add_column :users, :gift_shipping_first_name, :string, :limit => 60
    add_column :users, :gift_shipping_last_name, :string, :limit => 60
  end

  def self.down
    remove_column :users, :gift_shipping_first_name
    remove_column :users, :gift_shipping_last_name
  end
end
