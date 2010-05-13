class CreateNewsletterCategory < ActiveRecord::Migration
  def self.up
    create_table :newsletter_categories do |t|
      t.references :category
      t.references :newsletter
    end
  end

  def self.down
    drop_table :newsletter_categories
  end
end
