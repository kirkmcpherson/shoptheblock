class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions do |t|
      t.references  :merchant, :null => false
      t.references  :store
      t.string      :headline, :null => false, :limit => 60
      t.string      :description, :limit => 500
      t.datetime    :start_date
      t.datetime    :end_date
      t.integer     :audience, :default => Promotion::Audience[:members]

      t.string      :photo_file_name
      t.string      :photo_content_type
      t.integer     :photo_file_size
      t.datetime    :photo_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :promotions
  end
end
