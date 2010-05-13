class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table "users", :force => true do |t|
            t.column :first_name,                 :string, :limit => 50
            t.column :last_name,                  :string, :limit => 50
            t.column :email,                      :string, :limit => 100, :null => false
            t.column :crypted_password,           :string, :limit => 40, :null => false
            t.column :salt,                       :string, :limit => 40

            t.column :remember_token,             :string, :limit => 40
            t.column :remember_token_expires_at,  :datetime
            t.column :activation_code,            :string, :limit => 40
            t.column :activated_at,               :datetime
            t.column :password_reset_code,        :string, :limit => 40

            t.column :created_at,                 :datetime, :null => false
            t.column :updated_at,                 :datetime, :null => false

            t.column :status,                     :tinyint, :default => User::StatusFlags[:default], :null => false
            t.column :user_type,                  :tinyint, :null => false, :default => User::ROLES[:member]

            t.column :neighbourhood_address,        :string, :limit => 60
            t.column :neighbourhood_address2,       :string, :limit => 60
            t.column :neighbourhood_city,           :string, :limit => 40
            t.column :neighbourhood_province,       :string, :limit => 4    # Assumes using state/province code
            t.column :neighbourhood_postalcode,     :string, :limit => 20
            t.column :neighbourhood_country,        :string, :limit => 4    # Assumes using country code
            t.column :neighbourhood_lat,            :float
            t.column :neighbourhood_lng,            :float

            t.column(:newsletter,                 :tinyint, :default => User::NewsletterPreference[:weekly])
            t.column(:email_format,               :tinyint, :default => User::EmailFormat[:text])

            t.column :membership_expiration,        :datetime

            t.column :shipping_address,             :string, :limit => 60
            t.column :shipping_address2,            :string, :limit => 60
            t.column :shipping_city,                :string, :limit => 40
            t.column :shipping_province,            :string, :limit => 4    # Assumes using state/province code
            t.column :shipping_postalcode,          :string, :limit => 20
            t.column :shipping_country,             :string, :limit => 4    # Assumes using country code
            t.column :shipping_lat,                 :float
            t.column :shipping_lng,                 :float

        end

        add_index :users, :email, :unique => true
        add_index :users, :status
        add_index :users, :user_type
    end

    def self.down
        drop_table "users"
    end
end
