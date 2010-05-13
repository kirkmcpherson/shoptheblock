class CreateNewsletterAds < ActiveRecord::Migration
  def self.up
    create_table :newsletter_ads do |t|
      t.string :url
      t.references :newsletter

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_ads
  end
end
