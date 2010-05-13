class Newsletter < ActiveRecord::Base

  validates_presence_of :volume, :issue, :title

  has_many :stories, :class_name => 'NewsletterStory', :dependent => :destroy, :order => 'newsletter_stories.position ASC'
  has_many :ads,     :class_name => 'NewsletterAd',    :dependent => :destroy, :order => 'newsletter_ads.position ASC'
  has_many :newsletter_categories
  has_many :categories, :through => :newsletter_categories, :source => :category
  has_many :newsletter_recipients
  has_many :users, :through => :newsletter_recipients, :source => :user
  has_many :newsletter_stores
  has_many :stores, :through => :newsletter_stores, :source => :store
  before_save :check_publication_date


  # DON'T FORGET TO UPDATE THIS WHEN ADDING NEW PROPERTIES OR
  # ACTIVERECORD WILL IGNORE THE NEW VALUES IN THE OBJECT CONSTRUCTOR
  attr_accessible(
                  :volume,
                  :issue,
                  :title,
                  :recipient_method,
                  :expired,
                  :publication_date)

  ALL_RECIPIENTS         = 'all_recipients'
  RECIPIENTS_BY_CATEGORY = 'recipients_by_category'
  SELECT_RECIPIENTS      = 'select_recipients'

  def add_categories ids
    ids.to_a.each { |cat_id| newsletter_categories.create :category_id => cat_id }
  end

  def add_recipients ids
    ids.to_a.each { |user_id| newsletter_recipients.create :user_id => user_id }
  end

  def add_stores ids
    ids.to_a.each { |store_id| newsletter_stores.create :store_id => store_id }
  end

  def recipients
    case recipient_method
      when RECIPIENTS_BY_CATEGORY
        categories.collect(&:users).flatten.uniq
      when SELECT_RECIPIENTS
        users
      when ALL_RECIPIENTS
        User.newsletter_recipients
    end
  end

  def check_publication_date
    self.publication_date = self.created_at if  self.publication_date.nil?
  end

end
