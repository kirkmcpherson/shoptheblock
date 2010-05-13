class NewsItem < ActiveRecord::Base

  default_scope :order => "created_at DESC"

  named_scope :for_sidebar, 
              :order => "created_at DESC", 
              :limit => 10

  named_scope :expired, 
              :conditions => ["expiration_date < ?", Date.today]

  named_scope :active, 
              :conditions => ["expiration_date >= ?", Date.today]

  has_location

  has_attached_file :image, :whiny_thumbnails => true

  validates_format_of   :website, 
                        :with => /\A(?:http:\/\/)?(?:[a-z0-9\-_]+\.)+[a-z]{2,5}([\/?]\S*)?\Z/i, 
                        :allow_blank => true
  validates_length_of   :website, :maximum => 200, :allow_blank => true
  validates_presence_of :title, :description

  def website
    v = read_attribute(:website)
    return nil if v.nil?

    if v.match(/https?:\/\/(.*)/i)
      v = $1
    end
    return v
  end

  def website_url
    v = read_attribute(:website)
    return nil if v.nil?

    unless v.start_with?('http')
      v = 'http://' + v
    end
    return v
  end

end
