# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090930160142) do

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "categories_users", :id => false, :force => true do |t|
    t.integer "user_id",     :null => false
    t.integer "category_id", :null => false
  end

  add_index "categories_users", ["user_id", "category_id"], :name => "index_categories_users_on_user_id_and_category_id", :unique => true

  create_table "merchants", :force => true do |t|
    t.string   "name",              :limit => 50,   :null => false
    t.string   "web_site",          :limit => 200
    t.string   "description",       :limit => 1000
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchants_categories", :id => false, :force => true do |t|
    t.integer "merchant_id", :null => false
    t.integer "category_id", :null => false
  end

  add_index "merchants_categories", ["merchant_id", "category_id"], :name => "index_merchants_categories_on_merchant_id_and_category_id", :unique => true

  create_table "news_alerts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recipient_method", :default => "all_recipients"
  end

  create_table "news_items", :force => true do |t|
    t.string   "title",              :limit => 50, :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address",            :limit => 60
    t.string   "address2",           :limit => 60
    t.string   "city",               :limit => 40
    t.string   "province",           :limit => 4
    t.string   "postalcode",         :limit => 20
    t.string   "country",            :limit => 4
    t.float    "lat"
    t.float    "lng"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "website"
    t.date     "expiration_date"
  end

  create_table "newsletter_ads", :force => true do |t|
    t.string   "url"
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "position"
  end

  create_table "newsletter_categories", :force => true do |t|
    t.integer "category_id"
    t.integer "newsletter_id"
  end

  create_table "newsletter_recipients", :force => true do |t|
    t.integer  "newsletter_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_stores", :force => true do |t|
    t.integer  "newsletter_id"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletter_stories", :force => true do |t|
    t.text     "header"
    t.text     "title"
    t.text     "subtitle"
    t.text     "body"
    t.integer  "newsletter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "header_image_file_name"
    t.string   "header_image_content_type"
    t.integer  "header_image_file_size"
    t.datetime "header_image_updated_at"
    t.string   "body_image_file_name"
    t.string   "body_image_content_type"
    t.integer  "body_image_file_size"
    t.datetime "body_image_updated_at"
    t.string   "header_image_position"
    t.string   "body_image_position"
    t.text     "quote"
    t.integer  "position"
  end

  create_table "newsletters", :force => true do |t|
    t.integer  "volume"
    t.integer  "issue"
    t.string   "title"
    t.string   "recipient_method", :default => "all_recipients"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "expired"
  end

  create_table "press_releases", :force => true do |t|
    t.string   "title"
    t.string   "publication"
    t.string   "url"
    t.date     "publication_date"
    t.text     "article"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promo_codes", :force => true do |t|
    t.string   "code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "expiration_date"
  end

  create_table "promotions", :force => true do |t|
    t.integer  "merchant_id",                                       :null => false
    t.integer  "store_id"
    t.string   "headline",           :limit => 100,                 :null => false
    t.string   "description",        :limit => 1000
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "audience",                           :default => 1
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "promotion_type"
  end

  create_table "referrals", :force => true do |t|
    t.integer  "referrer_id"
    t.string   "referral_email"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_settings", :force => true do |t|
    t.float   "membership_cost"
    t.integer "membership_length"
    t.integer "signup_discount_referrals"
    t.float   "signup_discount_amount"
  end

  create_table "stores", :force => true do |t|
    t.integer  "merchant_id",                      :null => false
    t.string   "phone"
    t.string   "store_hours"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "address",            :limit => 60
    t.string   "address2",           :limit => 60
    t.string   "city",               :limit => 40
    t.string   "province",           :limit => 4
    t.string   "postalcode",         :limit => 20
    t.string   "country",            :limit => 4
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone_extension",    :limit => 10
  end

  create_table "testimonials", :force => true do |t|
    t.string   "person"
    t.string   "visibility"
    t.text     "quote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",                :limit => 50
    t.string   "last_name",                 :limit => 50
    t.string   "email",                     :limit => 100,                    :null => false
    t.string   "crypted_password",          :limit => 40,                     :null => false
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "status",                    :limit => 1,   :default => 0,     :null => false
    t.integer  "user_type",                 :limit => 1,   :default => 0,     :null => false
    t.string   "neighbourhood_address",     :limit => 60
    t.string   "neighbourhood_address2",    :limit => 60
    t.string   "neighbourhood_city",        :limit => 40
    t.string   "neighbourhood_province",    :limit => 4
    t.string   "neighbourhood_postalcode",  :limit => 20
    t.string   "neighbourhood_country",     :limit => 4
    t.float    "neighbourhood_lat"
    t.float    "neighbourhood_lng"
    t.integer  "newsletter",                :limit => 1,   :default => 1
    t.integer  "email_format",              :limit => 1,   :default => 0
    t.datetime "membership_expiration"
    t.string   "shipping_address",          :limit => 60
    t.string   "shipping_address2",         :limit => 60
    t.string   "shipping_city",             :limit => 40
    t.string   "shipping_province",         :limit => 4
    t.string   "shipping_postalcode",       :limit => 20
    t.string   "shipping_country",          :limit => 4
    t.float    "shipping_lat"
    t.float    "shipping_lng"
    t.integer  "card_num"
    t.string   "partner_name"
    t.integer  "heard_about_from",          :limit => 1
    t.string   "heard_about_from_name"
    t.integer  "promo_code_id"
    t.datetime "date_card_requested"
    t.datetime "date_card_shipped"
    t.integer  "search_distance"
    t.string   "partner_email"
    t.string   "gift_giver_first_name",     :limit => 50
    t.string   "gift_giver_last_name",      :limit => 50
    t.string   "gift_giver_email",          :limit => 100
    t.date     "gift_start_date"
    t.string   "partner_first_name"
    t.string   "partner_last_name"
    t.string   "gift_address",              :limit => 60
    t.string   "gift_address2",             :limit => 60
    t.string   "gift_city",                 :limit => 40
    t.string   "gift_province",             :limit => 4
    t.string   "gift_postalcode",           :limit => 20
    t.string   "gift_country",              :limit => 4
    t.float    "gift_lat"
    t.float    "gift_lng"
    t.boolean  "gift_address_is_receivers",                :default => true,  :null => false
    t.date     "member_since"
    t.string   "phone_number"
    t.boolean  "gift_message_sent",                        :default => false, :null => false
    t.string   "gift_shipping_first_name",  :limit => 60
    t.string   "gift_shipping_last_name",   :limit => 60   
    t.integer  "partner_newsletter",        :limit => 1,   :default => 1
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["status"], :name => "index_users_on_status"
  add_index "users", ["user_type"], :name => "index_users_on_user_type"

end
