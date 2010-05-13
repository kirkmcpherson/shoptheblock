class AddLocationVariablesToNewsItems < ActiveRecord::Migration
  def self.up
    add_column :news_items, :address,    :string, :limit => 60
    add_column :news_items, :address2,   :string, :limit => 60
    add_column :news_items, :city,       :string, :limit => 40
    add_column :news_items, :province,   :string, :limit => 4
    add_column :news_items, :postalcode, :string, :limit => 20
    add_column :news_items, :country,    :string, :limit => 4
    add_column :news_items, :lat, :float
    add_column :news_items, :lng, :float
  end

  def self.down
    remove_column :news_items, :address
    remove_column :news_items, :address2
    remove_column :news_items, :city
    remove_column :news_items, :province
    remove_column :news_items, :postalcode
    remove_column :news_items, :country
    remove_column :news_items, :lat
    remove_column :news_items, :lng
  end
end
