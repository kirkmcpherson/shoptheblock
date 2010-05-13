class Testimonial < ActiveRecord::Base

    validates_presence_of :person, :quote

    VISIBILITY_LEVELS = ['Featured', 'Hidden']

    named_scope :featured, :conditions => ['visibility = ?', 'Featured']

end
