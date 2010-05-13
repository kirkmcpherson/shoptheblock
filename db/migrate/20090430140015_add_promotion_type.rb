class AddPromotionType < ActiveRecord::Migration
  def self.up
    add_column :promotions, :promotion_type, :integer
  end

  def self.down
    remove_column :promotions, :promotion_type
  end
end
