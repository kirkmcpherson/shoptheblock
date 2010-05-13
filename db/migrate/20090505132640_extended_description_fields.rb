class ExtendedDescriptionFields < ActiveRecord::Migration
  def self.up

    change_column(
      :merchants,
      :description,
      :string,
      :limit => 1000
      )

    change_column(
      :promotions,
      :headline,
      :string,
      :null => false,
      :limit => 100
      )

    change_column(
      :promotions,
      :description,
      :string,
      :limit => 1000
      )

  end

  def self.down
  end
end
