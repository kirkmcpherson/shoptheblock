class CreatePressReleases < ActiveRecord::Migration
  def self.up
    create_table :press_releases do |t|
      t.string :title
      t.string :publication
      t.string :url
      t.date   :publication_date
      t.text   :article
      t.timestamps
    end
  end

  def self.down
    drop_table :press_releases
  end
end
