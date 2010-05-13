class Store < ActiveRecord::Base
    include StoresHelper

    # Relationships
    belongs_to              :merchant
    has_many                :promotions, :dependent => :destroy
    has_attached_file       :photo,
                            :styles => { :small  => "150x150>" },
                            :whiny_thumbnails => true,
                            :default_style => :small
    has_location            :auto_geocode => true 
    composed_of             :hours,
                            :class_name => '::StoresHelper::StoreHours',
                            :mapping => %w{store_hours hours_string},
                            :converter => :to_hours

    validates_presence_of   :address , :if  => Proc.new { |store| store.online?}
    validates_presence_of   :store_hours, :if => Proc.new { |store| store.online? }
    validates_length_of     :address, :maximum => 200
    validates_format_of     :phone, :with => /\A(?:\([1-9][0-9]{2}\)\s*)|(?:[1-9][0-9]{2}-?)[1-9][0-9]{2}-?[0-9]{4}\Z/, :message => 'Invalid phone number format', :allow_nil => true
    validates_format_of     :store_hours, :with => ::StoresHelper::StoreHours::Pattern ,:if => Proc.new { |store| store.online? }


    def hours_from_form=(val)        
        self.hours = hours_from_form(val)
    end



    def self.search(loc, distance, category=nil)

        assert_location_arg(loc)
        #throw ArgumentError.new('Expected Location instance') unless loc.is_a?(Location)

        unless category.nil? || (category == 0)

            dist_sql = distance_sql(Store.new(:lat => loc.lat, :lng => loc.lng)).gsub('stores', 's')
            sql = [%{
                SELECT DISTINCT s.id, s.*, (#{dist_sql}) AS distance FROM stores AS s
                INNER JOIN merchants m ON (s.merchant_id = m.id)
                INNER JOIN merchants_categories mc on (m.id = mc.merchant_id)
                WHERE (mc.category_id #{category.is_a?(Array) ? 'IN(?)' : '= ?'}) AND (#{dist_sql} <= ?)
                ORDER BY (#{dist_sql}) ASC
                },
                category, distance
                ]
            return Store.find_by_sql(sql)
        else
            return Store.find(:all, :origin => loc.latlng, :within => distance, :order => "distance")
        end
    end

    def all_promotions
        return Promotion.find(:all, :conditions => ['store_id = ? OR (merchant_id = ? AND store_id IS NULL)', self, self.merchant_id])
    end

    def all_discounts
      return Promotion.find(:all, :conditions => ["(store_id = ? OR (merchant_id = ? AND store_id IS NULL)) AND promotion_type = ?", self, self.merchant_id, Promotion::Type[:discount]])
    end

    def all_promo_except_discounts
      return Promotion.find(:all, :conditions => [
          "(store_id = ? OR (merchant_id = ? AND store_id IS NULL))" \
            " AND promotion_type = ?" \
            " AND (DATE(end_date) >= DATE(NOW()))",
          self,
          self.merchant_id, Promotion::Type[:promotion]
        ])
    end
    
    def online?
      logger.info  " online   #{online.to_s}"
       online == 0 ?  true : false
    end

end
