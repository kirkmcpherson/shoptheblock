class CreateNewsletterStories < ActiveRecord::Migration
  def self.up
    create_table :newsletter_stories do |t|
      t.text :header
      t.text :title
      t.text :subtitle
      t.text :body
      t.references :newsletter

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_stories
  end
end
