class AddPromoCodeIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :promo_code_id, :integer
  end

  def self.down
    remove_column :users, :promo_code_id
  end
end
