class Category < ActiveRecord::Base
    has_and_belongs_to_many     :merchants, :join_table => 'merchants_categories'
    has_and_belongs_to_many     :users

    has_many                    :newsletter_categories
    has_many                    :newsletters, :through => :newsletter_categories


    validates_presence_of       :name

    def to_s
        return self.name
    end
end
