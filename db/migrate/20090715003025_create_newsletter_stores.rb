class CreateNewsletterStores < ActiveRecord::Migration
  def self.up
    create_table :newsletter_stores do |t|
      t.references :newsletter
      t.references :store
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_stores
  end
end
