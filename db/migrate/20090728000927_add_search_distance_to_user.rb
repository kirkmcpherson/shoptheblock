class AddSearchDistanceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :search_distance, :integer

    # default everyone to 20
    update 'UPDATE users SET search_distance = 20'
  end

  def self.down
    remove_column :users, :search_distance
  end
end
