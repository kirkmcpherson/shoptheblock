class NewsletterCategory < ActiveRecord::Base

  belongs_to :newsletter
  belongs_to :category

end
