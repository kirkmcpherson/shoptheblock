class AddAttachmentsImageToNewsletterStory < ActiveRecord::Migration
  def self.up
    add_column :newsletter_stories, :image_file_name, :string
    add_column :newsletter_stories, :image_content_type, :string
    add_column :newsletter_stories, :image_file_size, :integer
    add_column :newsletter_stories, :image_updated_at, :datetime
  end

  def self.down
    remove_column :newsletter_stories, :image_file_name
    remove_column :newsletter_stories, :image_content_type
    remove_column :newsletter_stories, :image_file_size
    remove_column :newsletter_stories, :image_updated_at
  end
end
