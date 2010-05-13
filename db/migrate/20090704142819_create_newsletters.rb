class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.integer :volume
      t.integer :issue
      t.string  :title
      t.boolean :recipients_by_category

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
