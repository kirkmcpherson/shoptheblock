class AddHowIHeard < ActiveRecord::Migration
  def self.up
    add_column :users, :heard_about_from, :tinyint
    add_column :users, :heard_about_from_name, :string
  end

  def self.down
    remove_column :users, :heard_about_from_name
    remove_column :users, :heard_about_from
  end
end
