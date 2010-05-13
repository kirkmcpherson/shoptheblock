class Promotion < ActiveRecord::Base

    #===========================================================================
    #
    # Constants
    #
    #===========================================================================

    Audience = {
        :all => 0,
        :members => 1
    }

    Type = {
      :discount => 0,
      :promotion => 1
    }
    #===========================================================================
    #
    # Associations
    #
    #===========================================================================

    belongs_to  :merchant
    belongs_to  :store

    has_attached_file :photo

    #===========================================================================
    #
    # Validation
    #
    #===========================================================================


    validates_presence_of :headline, :merchant_id

    validates_inclusion_of(
        :audience,
        :in => Audience.values,
        :message => 'is invalid'
    )
    validate :proper_dates, :if => :promotion?

    validates_length_of :headline, :maximum => 100
    validates_length_of :description, :maximum => 1000, :allow_blank => true

    #===========================================================================
    #
    # Public Methods
    #
    #===========================================================================

    attr_accessible :headline, :description, :start_date, :end_date, :promotion_type, :merchant_id, :store_id

    def format_dates
        
        if (self.start_date.nil?)
            if (self.end_date.nil?)
                return 'Anytime'
            else
                return self.end_date.strftime("Until %x")
            end
        else
            if (self.end_date.nil?)
                return self.start_date.strftime("Starting %x")
            else
                return sprintf(
                    "From %s to %s",
                    self.start_date.strftime("%x"),
                    self.end_date.strftime("%x")
                )
            end
        end

    end

    #
    # Locates promotions based on the given criteria:
    #
    # :location
    #   nil or a Location object defining the origin of the distance-based search.
    #   If this is not nil then :distance must also be specified
    #
    # :distance
    #   Specifies the radius of the distance-based search. Ignored if :location
    #   is not provided.
    #
    # :type (String/Symbol)
    #   all         All promotions
    #   discount    Promotions that have no start or end date
    #   promo       Promotions that have start and/or end date
    #
    # :merchant
    #   Filters the search to promotions for the given merchant
    #
    # :store
    #   Filters the search to promotions for the given store
    #
    # :mode (String/Symbol)
    #   Determines how to return results for promotions that apply to all
    #   of a merchant's stores
    #
    #   merchant    If a promotion is for all stores, return a single result
    #               with the store_id set to nil
    #
    #   store       If a promotion is for all stores, return a result for
    #               each store within the search radius and set store_id
    #               accordingly
    #
    def self.search(options={})

        location        = options[:location]
        distance        = options[:distance]
        promo_type  = options[:type]
        category        = options[:category]
        merchant        = options[:merchant]
        store           = options[:store]
        mode            = options[:mode]

        mode            ||= location.nil? ? :merchant : :store
        promo_type  ||= :all
        category        ||= nil

        select = [
            "p.id",
            "p.headline",
            "p.description",
        ]

        from = [
            "promotions p",

        ]

        where = []
        params = []
        select_modifiers = []
        query_options = []

        case mode
        when :merchant
            from << "merchants m ON (p.merchant_id = m.id)"
            select << "p.merchant_id"
            select << "p.store_id"
        when :store
            from << "stores s ON (p.store_id = s.id OR p.merchant_id = s.merchant_id AND p.store_id IS NULL)"
            from << "merchants m ON (s.merchant_id = m.id)"
            select << "s.id AS store_id"
            select << "s.merchant_id"
        else
            throw ArgumentError.new("Invalid search mode '#{mode}'")
        end

        unless category.nil? || (category == 0)
            from << "merchants_categories mc ON (m.id = mc.merchant_id)"
            if category.is_a?(Array)
                where << "mc.category_id IN(?)"
                params << category
            else
                where << "mc.category_id = ?"
                params << category
            end
        end

        unless merchant.nil?
            where << "m.id = ?"
            params << merchant.id
        end

        unless store.nil?
            where << "s.id = ?"
            params << store.id
        end

        case promo_type.to_sym
        when :discount
            where << "(p.start_date IS NULL) AND (p.end_date IS NULL)"
        when :promo
            where << "NOT((p.start_date IS NULL) AND (p.end_date IS NULL))"
            where << "((p.end_date IS NULL) OR (DATE(p.end_date) >= DATE(NOW())))"
            where << "((p.start_date IS NULL) OR (DATE(p.start_date) <= DATE(NOW())))"
        when :all
        else
            throw ArgumentError.new("Invalid promotion type: #{promo_type}")
        end

        unless location.nil?
            assert_location_arg(location)
            throw ArgumentError.new if distance.nil?

            dist_sql = Store.distance_sql(Store.new(:lat => location.lat, :lng => location.lng)).gsub('stores', 's')

            select << "(#{dist_sql}) AS distance"
            where << "#{dist_sql} <= ?"
            params << distance
            query_options << "ORDER BY (#{dist_sql}) ASC"
        end

        query = %{
            SELECT DISTINCT #{select_modifiers.join(' ')}
                #{select.join(",\n")}
            FROM #{from.join("\n INNER JOIN ")}
            WHERE #{where.collect{|w| "#{w}"}.join("\nAND\n")}
            #{query_options.join("\n")}
        }

        promos = Promotion.find_by_sql(params.insert(0, query))
        return promos
        
    end

    def proper_dates
      if !end_date
        if !start_date
          errors.add(:start_date, "or end date is required")
        end
      else
        errors.add(:end_date, "can't be before current date") if end_date < Date.today
        errors.add(:end_date, "can't be before the start date") if start_date && end_date < start_date
      end
    end

    def promotion?
      promotion_type == Type[:promotion]
    end
end
