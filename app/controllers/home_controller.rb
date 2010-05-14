
class HomeController < ApplicationController
  include LocationHelper
  include ApplicationHelper
   
  SearchPageSize = 10
   
  def welcome
    if logged_in?
      case current_user.role
      when :member then 
        if(!current_user.nil? && current_user.expired?)
          redirect_to renew_url
        else
          redirect_to neighbourhood_url
        end
        #TODO: when :merchant then ?
      when :administrator then redirect_to account_url
      end
    end
  end

  def neighbourhood
    get_location

    if @location.nil?
      @news_items_for_sidebar = NewsItem.for_sidebar.active.find :all,  :within => 10
    else
       @news_items_for_sidebar = NewsItem.for_sidebar.active.find :all, :origin => @location.latlng, :within => 10   
    end
  end

  def validate_address

    has_city_or_postal = false
    address = ''

    ['address','city','postal'].each do |s|
   
      valid = params["#{s}_valid".to_sym] == '1'
      val = params[s.to_sym];

      if (valid && !val.blank?)
        address = address + ', ' unless address.blank?
        address = address + val  

        has_city_or_postal = true if s == 'city' || s == 'postal'
      end

    end

    unless has_city_or_postal
      render :text => t('home.validate_address.city_or_postal'), :status => 201
    else
      address = address + ', Canada'
      loc = Location.from_address(address)

      if (loc.valid?)
        set_location_to(loc)
        save_location
        render :text => '', :status => 200
      else
        render :text => t('home.validate_address.failed'), :status => 201
      end
    end
  end

  def tbd
  end

  def faq
  end

  def company_info
  end
    
  def news
  end
    
  def participating_stores
    @type = params[:active_Tab].blank? ? 'all_store': params[:active_Tab]
    @merchants = Merchant.all(:order => 'name ASC')
    @location = Location.from_address('Toronto')
  end

  def participating_stores_neighbourhood
    @type = params[:active_Tab].blank? ? 'myneighbourhood': params[:active_Tab]
    @text = t('search.participating_store_after_search') 
    @merchants = Merchant.all(:order => 'name ASC')
    @location = Location.from_address('Toronto')
  end

  def support
  end

  def legal
  end

  def privacy
  end
    
  def contact
  end
    
  def how_it_works
  end

  #===========================================================================
  #
  # neighbourhood_search
  #
  # Called asyncronously from the "My neighbourhood" page to render
  # search results
  #
  def neighbourhood_search
   
    get_location()

    @startFrom

    if params[:category] == '*'
      category_id = nil
    elsif params[:category].start_with?('@')
      category_id = params[:category][1..-1].split(',').collect{|s| s.to_i}
    else
      category_id = params[:category].to_i
    end

    distance = params[:distance].to_i
    result_type = params[:type]

    if (result_type == 'store')
      @item_type = 'store'
      @items = Store.search(@location, distance, category_id)

    else
      @item_type = 'promotion'
      @items = Promotion.search(
        :location => @location,
        :distance => distance,
        :type => result_type,
        :category => category_id
      )
	
	    
    end

    @itemsLength = @items.length
    @numberOfPages = (@items.length / SearchPageSize)

    if (@items.length % SearchPageSize) != 0
      @numberOfPages = @numberOfPages + 1
    end

    @currentPage = params[:pageIndex].to_i
    @startFrom = @currentPage * SearchPageSize
    @startFrom = 0 if @startFrom > @items.length
    @items = @items[@startFrom,SearchPageSize]
        
    render :template => 'home/neighbourhood_search', :layout => false
  end
end
