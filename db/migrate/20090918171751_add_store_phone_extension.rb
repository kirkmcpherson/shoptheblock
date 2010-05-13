class AddStorePhoneExtension < ActiveRecord::Migration
  def self.up
    add_column :stores, :phone_extension ,:string , :limit => 10
  end

  def self.down
    remove_column :stores, :phone_extension
  end
end
