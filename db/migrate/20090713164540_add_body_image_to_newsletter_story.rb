class AddBodyImageToNewsletterStory < ActiveRecord::Migration
  def self.up
    rename_column :newsletter_stories, :image_file_name,    :header_image_file_name
    rename_column :newsletter_stories, :image_content_type, :header_image_content_type
    rename_column :newsletter_stories, :image_file_size,    :header_image_file_size
    rename_column :newsletter_stories, :image_updated_at,   :header_image_updated_at

    add_column :newsletter_stories, :body_image_file_name,    :string
    add_column :newsletter_stories, :body_image_content_type, :string
    add_column :newsletter_stories, :body_image_file_size,    :integer
    add_column :newsletter_stories, :body_image_updated_at,   :datetime

    add_column :newsletter_stories, :header_image_position, :string
    add_column :newsletter_stories, :body_image_position,   :string
  end

  def self.down
    rename_column :newsletter_stories, :header_image_file_name,    :image_file_name
    rename_column :newsletter_stories, :header_image_content_type, :image_content_type
    rename_column :newsletter_stories, :header_image_file_size,    :image_file_size
    rename_column :newsletter_stories, :header_image_updated_at,   :image_updated_at

    remove_column :newsletter_stories, :header_image_file_name
    remove_column :newsletter_stories, :header_image_content_type
    remove_column :newsletter_stories, :header_image_file_size
    remove_column :newsletter_stories, :header_image_updated_at

    remove_column :newsletter_stories, :header_image_position
    remove_column :newsletter_stories, :body_image_position 
  end
end
