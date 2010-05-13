class CreateStores < ActiveRecord::Migration
    def self.up
        create_table :stores do |t|

            t.references  :merchant, :null => false
            t.column      :phone, :string
            t.column      :store_hours, :string
      
            t.string      :photo_file_name
            t.string      :photo_content_type
            t.integer     :photo_file_size
            t.datetime    :photo_updated_at

            t.column :address,        :string, :limit => 60
            t.column :address2,       :string, :limit => 60
            t.column :city,           :string, :limit => 40
            t.column :province,       :string, :limit => 4
            t.column :postalcode,     :string, :limit => 20
            t.column :country,        :string, :limit => 4
            t.column :lat,            :float
            t.column :lng,            :float

            t.timestamps
        end
    end

    def self.down
        drop_table :stores
    end
end
