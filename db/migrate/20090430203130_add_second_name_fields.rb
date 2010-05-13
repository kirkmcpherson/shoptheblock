class AddSecondNameFields < ActiveRecord::Migration
  def self.up
    add_column :users, :partner_name, :string
  end

  def self.down
    remove_column :users, :partner_name
  end
end
