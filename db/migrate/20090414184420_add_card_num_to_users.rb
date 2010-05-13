class AddCardNumToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :card_num, :integer
  end

  def self.down
    remove_column :users, :card_num
  end
end
