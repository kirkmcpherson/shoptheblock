class NewsletterAd < ActiveRecord::Base

  validates_presence_of :url
  validate :url_must_be_valid

  belongs_to :newsletter

  has_attached_file :image

  def url_must_be_valid
    if url.blank? || url == 'http://'
      errors.add(:url, I18n.translate('newsletter_ad.create.invalid_url'))
    end
  end

  def delete_image= delete
    self.image = nil if delete == 'true'
  end

end
