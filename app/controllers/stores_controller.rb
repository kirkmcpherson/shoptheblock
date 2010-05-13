class StoresController < ApplicationController

  requires_role :merchant, :except => [ :show ]

  def index
    @stores = Store.find(:all)
  end

  def show
    @store = Store.find(params[:id])
  end

  def new
    @store = Store.new(:merchant_id => params[:merchant_id])
    @merchant = Merchant.find(@store.merchant_id)
  end

  def edit
    @store = Store.find(params[:id])
    @merchant = Merchant.find(@store.merchant_id)
  end

  def create
    @store = Store.new(params[:store])
    # if the merchant changed store's address , we would change location on the map
    # the location is only for google map view, the address is for text field 
    @store.location = made_location
    @store.address = params[:store][:address]
    @store.merchant_id = params[:merchant_id]

    if @store.save
      save_location_user_settings @store , params[:store]
      flash[:notice] = t('stores.create.succeeded')
      redirect_to(@store)
    else
      render :action => 'new'
    end
  end

  def update
    @store = Store.find(params[:id])    
    @store.location = made_location
    @store.store_hours = params[:store][:hours_from_form] if params[:store][:hours_from_form].blank?
    @store.online = 0  if params[:store][:online].blank?
    
    if @store.update_attributes(params[:store])
       save_location_user_settings @store , params[:store]
      flash[:notice] = t('stores.update.succeeded')
      redirect_to(@store)
    else
      render :action => "edit"
    end
  end

  def destroy
    @store = Store.find(params[:id])
    merchant = @store.merchant_id
    @store.destroy
    redirect_to(merchant_url(merchant))
  end

  
  private
  def made_location
   location = ""
   location += "#{params[:store][:address]}"  if params[:store][:address]
   location += ",#{params[:store][:address2]}"  if params[:store][:address2]
   location += ",#{params[:store][:city] }"  if  params[:store][:city]
   location += ",#{params[:store][:postalcode]}" if params[:store][:postalcode]

    return nil if location.blank?
    return location
  end

  def save_location_user_settings store,params_data
    store.update_attribute(:address, params_data[:address])  if store.address != params_data[:address] && !params_data[:address].blank?
    store.update_attribute(:address2, params_data[:address2])  if store.address2 != params_data[:address2] && !params_data[:address2].blank?
    store.update_attribute(:city, params_data[:city])  if store.city != params_data[:city] && !params_data[:city].blank?
    store.update_attribute(:postalcode, params_data[:postalcode])  if store.postalcode != params_data[:postalcode] &&  !params_data[:postalcode].blank?
  end

end
