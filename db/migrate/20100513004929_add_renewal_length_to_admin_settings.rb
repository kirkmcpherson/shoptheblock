class AddRenewalLengthToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings,:renewal_length,:integer,:default=> 12
    add_column :site_settings,:early_renewal_length,:integer,:default=> 13
  end

  def self.down
    remove_column :site_settings,:renewal_length
    remove_column :site_settings,:early_renewal_length
  end
end
