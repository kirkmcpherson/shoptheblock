class CreateMerchants < ActiveRecord::Migration
  def self.up
    create_table :merchants do |t|
      t.string      :name, :null => false, :limit => 50
      t.string      :web_site, :limit => 200
      t.string      :description, :limit => 400

      t.string      :logo_file_name
      t.string      :logo_content_type
      t.integer     :logo_file_size
      t.datetime    :logo_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :merchants
  end
end
