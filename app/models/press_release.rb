class PressRelease < ActiveRecord::Base

  HTTP_URL  =  'http://'
  validates_presence_of :title, :article, :publication, :publication_date

 before_save  :check_url

   def check_url
          if self.url == HTTP_URL
            return self.url = nil
          end
          if( URI.extract(self.url).length == 0 )
            self.url = HTTP_URL + self.url
         end
   end

end
