class NewsletterStore < ActiveRecord::Base

  belongs_to :newsletter
  belongs_to :store

end
