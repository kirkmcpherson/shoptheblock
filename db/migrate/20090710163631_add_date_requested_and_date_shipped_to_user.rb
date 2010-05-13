class AddDateRequestedAndDateShippedToUser < ActiveRecord::Migration

  def self.up
    add_column :users, :date_card_requested, :datetime
    add_column :users, :date_card_shipped, :datetime
  end

  def self.down
    remove_column :users, :date_card_requested
    remove_column :users, :date_card_shipped
  end

end
