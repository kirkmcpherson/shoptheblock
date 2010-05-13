class AddMemberSinceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :member_since, :date
  end

  def self.down
    remove_column :users, :member_since
  end
end
