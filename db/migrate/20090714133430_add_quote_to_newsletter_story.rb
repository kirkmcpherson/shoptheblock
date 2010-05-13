class AddQuoteToNewsletterStory < ActiveRecord::Migration
  def self.up
    add_column :newsletter_stories, :quote, :text
  end

  def self.down
    remove_column :newsletter_stories, :quote
  end
end
