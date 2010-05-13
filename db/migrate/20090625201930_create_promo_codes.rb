class CreatePromoCodes < ActiveRecord::Migration
  def self.up
    create_table :promo_codes do |t|
      t.string :code
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :promo_codes
  end
end
