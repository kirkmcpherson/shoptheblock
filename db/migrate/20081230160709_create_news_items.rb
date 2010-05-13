class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.string      :title, :null => false, :limit => 50
      t.text      :description
      t.references  :merchant
      t.references  :store

      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
