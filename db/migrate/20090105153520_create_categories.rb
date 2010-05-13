class CreateCategories < ActiveRecord::Migration
    def self.up

        create_table :categories do |t|
            t.string :name

        end

        create_table :merchants_categories, :id => false do |t|
            t.references    :merchant, :null => false
            t.references    :category, :null => false
        end

        add_index(:merchants_categories, [:merchant_id, :category_id], :unique => true)

        create_table :categories_users, :id => false do |t|
            t.references  :user, :null => false
            t.references  :category, :null => false
        end

        add_index(:categories_users, [:user_id, :category_id], :unique => true)

    rescue x

        self.down
        throw x
    end

    def self.down
        begin
            drop_table :merchants_categories
        rescue
        end
        begin
            drop_table :categories_users
        rescue
        end
        begin
            drop_table :categories
        rescue
        end
    end
end
