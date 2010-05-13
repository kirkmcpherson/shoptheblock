class NewsletterStory < ActiveRecord::Base
  
  validates_presence_of :body

  belongs_to :newsletter

  has_attached_file :header_image
  has_attached_file :body_image

  HEADER_IMAGE_POSITIONS = %w(Top Left Right)
  BODY_IMAGE_POSITIONS   = %w(Right Left)

  def delete_header_image= delete
    self.header_image = nil if delete == 'true'
  end

  def delete_body_image= delete
    self.body_image = nil if delete == 'true'
  end

  def sanitized_body
    # <br/>'s --> \n's
    new_body = body.gsub(/<br \/>/, "\n\n")

    # <a href="http://www.shoptheblock.ca">STB</a> --> STB (http://www.shoptheblock.ca)
    new_body.gsub(/<a.*href="(mailto:)?(.*?)".*?>(.*)<\/a>/, '\3 (\2)')
  end

end
