class AddRenewalCostToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings,:renewal_cost,:float,:default=> 60
    add_column :site_settings,:early_renewal_cost,:float,:default=> 60
  end

  def self.down
    remove_column :site_settings,:renewal_cost
    remove_column :site_settings,:early_renewal_cost
  end
end
