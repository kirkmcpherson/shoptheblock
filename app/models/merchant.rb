class Merchant < ActiveRecord::Base

    #===========================================================================
    #
    # Associations
    #
    #===========================================================================

    has_many      :stores,        :dependent => :destroy
    has_many      :promotions,    :dependent => :destroy
    has_and_belongs_to_many :categories, :join_table => 'merchants_categories'

    has_attached_file(
      :logo,
      :whiny_thumbnails => true,
      :styles => { :thumb => '180x60>' }
      )

    #===========================================================================
    #
    # Validation
    #
    #===========================================================================

    validates_presence_of   :name
    validates_length_of     :name, :maximum => 50
    validates_length_of     :description, :maximum => 1000, :allow_blank => true
    validates_length_of     :web_site, :maximum => 200, :allow_blank => true
    validates_format_of     :web_site, :with => /\A(?:http:\/\/)?(?:[a-z0-9\-_]+\.)+[a-z]{2,5}([\/?]\S*)?\Z/i, :allow_blank => true
  
    #===========================================================================
    #
    # Public Methods
    #
    #===========================================================================

    def find_discounts(location=nil, distance=nil)

        Promotion.search(
            :location => location,
            :distance => distance,
            :merchant => self,
            :type => :discount,
            :mode => :merchant
        )

    end

    def find_promotions(location=nil, distance=nil)

        Promotion.search(
            :location => location,
            :distance => distance,
            :merchant => self,
            :type => :promo,
            :mode => :merchant
        )

    end

    def web_site

      v = read_attribute(:web_site)
      return nil if v.nil?

      if v.match(/https?:\/\/(.*)/i)
        v = $1
      end

      return v
    end

    def web_site_url

      v = read_attribute(:web_site)
      return nil if v.blank?

      unless v.start_with?('http')
        v = 'http://' + v
      end

      return v
    end

    def has_stores_with_location?
        stores.all.each do |store|
          return true unless store.address.blank?
        end
      
        return false
    end

 def has_stores_online?
      stores.all.each do |store|
          unless store.online?
              return true
          end
      end
        return false
    end

end
