class AddPositionToNewsletterItems < ActiveRecord::Migration
  def self.up
    add_column :newsletter_stories, :position, :integer
    add_column :newsletter_ads,     :position, :integer

    NewsletterStory.reset_column_information
    NewsletterAd.reset_column_information

    Newsletter.all.each do |n|
      n.stories.each_with_index do |s, i|
        s.update_attribute :position, i
      end
      n.ads.each_with_index do |a, i|
        a.update_attribute :position, i
      end
    end
  end

  def self.down
    remove_column :newsletter_stories, :position
    remove_column :newsletter_ads,     :position
  end
end
