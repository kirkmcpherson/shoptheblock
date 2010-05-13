class AddGiftMessageSentToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :gift_message_sent, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :gift_message_sent
  end
end
