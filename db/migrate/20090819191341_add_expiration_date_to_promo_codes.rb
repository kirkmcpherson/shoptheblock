class AddExpirationDateToPromoCodes < ActiveRecord::Migration

  def self.up
    add_column :promo_codes, :expiration_date, :date
  end

  def self.down
    remove_column :promo_codes, :expiration_date
  end

end
