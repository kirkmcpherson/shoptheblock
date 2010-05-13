class RemoveNewsItemAssociations < ActiveRecord::Migration
  def self.up
    remove_column :news_items, :merchant_id
    remove_column :news_items, :store_id
  end

  def self.down
    add_column :news_items, :merchant_id, :integer
    add_column :news_items, :store_id, :integer
  end
end
