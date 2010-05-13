class PromoCode < ActiveRecord::Base

    #===========================================================================
    #
    # Validation
    #
    #===========================================================================

    validates_presence_of :code

    validates_uniqueness_of :code

    validates_length_of :description, :maximum => 1000, :allow_blank => true

    named_scope :expired,
              :conditions => ["expiration_date < ?", Date.today]

    named_scope :active,
              :conditions => ["expiration_date >= ? OR  expiration_date  IS NULL ", Date.today]

    def to_s
      code
    end

    def expired?
      self.expiration_date.nil? ? false : self.expiration_date < Date.today
    end

end
