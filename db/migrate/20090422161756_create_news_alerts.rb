class CreateNewsAlerts < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string :title
      t.text :body
      
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
