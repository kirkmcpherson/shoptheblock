class NewsItemsController < ApplicationController

  before_filter :requires_administrator_role, :except => [:show, :index]

  # GET /news_items
  # GET /news_items.xml
  def index
    @active_news_items = NewsItem.active
    @expired_news_items = NewsItem.expired
    @newsletters = Newsletter.all(:order => 'newsletters.publication_date DESC',
                                  :conditions => ['expired = ?', true])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news_items }
    end
  end

  # GET /news_items/1
  # GET /news_items/1.xml
  def show
    @news_item = NewsItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_items/new
  # GET /news_items/new.xml
  def new
    @news_item = NewsItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_items/1/edit
  def edit
    @news_item = NewsItem.find(params[:id])
  end

  # POST /news_items
  # POST /news_items.xml
  def create
    params[:news_item][:location] = made_location
    @news_item = NewsItem.new(params[:news_item])
   
    respond_to do |format|
      if @news_item.save
        save_location_user_settings @news_item ,params[:news_item]
        flash[:notice] = 'News Item was successfully created.'
        format.html { redirect_to(@news_item) }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news_items/1
  # PUT /news_items/1.xml
  def update
    @news_item = NewsItem.find(params[:id])
    params[:news_item][:location] = made_location
    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        save_location_user_settings  @news_item,params[:news_item]
        flash[:notice] = 'News Item was successfully updated.'
        format.html { redirect_to(@news_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news_items/1
  # DELETE /news_items/1.xml
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy

    respond_to do |format|
      format.html { redirect_to(news_items_url) }
      format.xml  { head :ok }
    end
  end


  private
  def made_location
   location = ""
   location += "#{params[:news_item][:address]}"  if params[:news_item][:address]
   location += ",#{params[:news_item][:address2]}"  if params[:news_item][:address2]
   location += ",#{params[:news_item][:city] }"  if  params[:news_item][:city]
   location += ",#{params[:news_item][:postalcode]}" if params[:news_item][:postalcode]

    return nil if location.blank?
    return location
  end

  def save_location_user_settings news_item,params_data
    news_item.update_attribute(:address, params_data[:address])  if news_item.address != params_data[:address] && !params_data[:address].blank?
    news_item.update_attribute(:address2, params_data[:address2])  if news_item.address2 != params_data[:address2] && !params_data[:address2].blank?
    news_item.update_attribute(:city, params_data[:city])  if news_item.city != params_data[:city] && !params_data[:city].blank?
    news_item.update_attribute(:postalcode, params_data[:postalcode])  if news_item.postalcode != params_data[:postalcode] &&  !params_data[:postalcode].blank?
  end
end
