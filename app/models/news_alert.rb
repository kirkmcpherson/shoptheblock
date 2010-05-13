class NewsAlert < ActiveRecord::Base

  ALL_RECIPIENTS         = 'all_recipients'
  RECIPIENTS_BY_CATEGORY = 'recipients_by_category'
  SELECT_RECIPIENTS      = 'select_recipients'

  attr_accessor :users
  attr_accessor :categories

  def categories= categories
    @categories = (categories.nil?) ? [] : 
      @categories = categories.inject([]) { |all, cat_id| all << Category.find(cat_id.to_i) }
  end

  def users= users
    @users = (users.nil?) ? [] : 
      @users = users.inject([]) { |all, user_id| all << User.find(user_id.to_i) }
  end

  def recipients
    case recipient_method
      when RECIPIENTS_BY_CATEGORY
        @categories.collect(&:users).flatten.uniq
      when SELECT_RECIPIENTS
        @users
      when ALL_RECIPIENTS
        User.newsletter_recipients
    end
  end

end

