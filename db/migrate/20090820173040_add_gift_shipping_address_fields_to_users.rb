class AddGiftShippingAddressFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gift_address, :string, :limit => 60
    add_column :users, :gift_address2, :string, :limit => 60
    add_column :users, :gift_city, :string, :limit => 40
    add_column :users, :gift_province, :string, :limit => 4
    add_column :users, :gift_postalcode, :string, :limit => 20
    add_column :users, :gift_country, :string, :limit => 4
    add_column :users, :gift_lat, :float
    add_column :users, :gift_lng, :float
    add_column :users, :gift_address_is_receivers, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :gift_address
    remove_column :users, :gift_address2
    remove_column :users, :gift_city
    remove_column :users, :gift_province
    remove_column :users, :gift_postalcode
    remove_column :users, :gift_country
    remove_column :users, :gift_lat
    remove_column :users, :gift_lng
    remove_column :users, :gift_address_is_receivers
  end
end
