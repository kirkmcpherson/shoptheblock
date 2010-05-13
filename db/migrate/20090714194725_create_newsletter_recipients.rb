class CreateNewsletterRecipients < ActiveRecord::Migration
  def self.up
    create_table :newsletter_recipients do |t|
      t.references :newsletter
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_recipients
  end
end
