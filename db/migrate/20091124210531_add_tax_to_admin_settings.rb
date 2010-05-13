class AddTaxToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings,:tax_percent,:float,:default=> 5
  end

  def self.down
     remove_column :site_settings,:tax_percent
  end
end
