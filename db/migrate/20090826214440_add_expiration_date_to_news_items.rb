class AddExpirationDateToNewsItems < ActiveRecord::Migration

  def self.up
    add_column    :news_items, :expiration_date, :date
    rename_column :news_items, :url, :website

    one_year_from_now = Date.today + 1.year
    NewsItem.all.each do |ni|
      ni.update_attribute(:expiration_date, one_year_from_now)
      puts "set news_item #{ni.id}'s expiration date to #{one_year_from_now}"
    end
  end

  def self.down
    remove_column :news_items, :expiration_date
    rename_column :news_items, :website, :url
  end

end
