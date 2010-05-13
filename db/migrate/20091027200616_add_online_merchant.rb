class AddOnlineMerchant < ActiveRecord::Migration
  def self.up
   add_column :stores,:online, :tinyint,:default =>0
  end

  def self.down
    remove_column :stores,  :online
  end
end
