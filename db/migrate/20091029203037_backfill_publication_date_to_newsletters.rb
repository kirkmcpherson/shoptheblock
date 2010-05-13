class BackfillPublicationDateToNewsletters < ActiveRecord::Migration
  def self.up
     
  
     Newsletter.all.each do |newsletter|
       # only if publication_date is null
        
     
         
       # for order by publication date
       say "Updated."
      newsletter.update_attribute(:publication_date,newsletter.created_at) if newsletter.publication_date.nil?
       say "Updated.   #{newsletter.publication_date.to_s}"
     

  end
  end

  def self.down
  end
end
