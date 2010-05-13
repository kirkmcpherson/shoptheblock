class AddPublishedDateToNewsletter < ActiveRecord::Migration
  def self.up
    add_column :newsletters,  :publication_date, :datetime
  end

  def self.down
    remove_column :newsletters,  :publication_date
  end
end
