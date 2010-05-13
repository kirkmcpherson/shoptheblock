class PromotionsController < ApplicationController
    requires_role :merchant, :except => [:show]

    def new
        @promotion = Promotion.new(:merchant_id => params[:merchant_id], :store_id => params[:store_id])
        @promotion.promotion_type = params[:promo] ? Promotion::Type[:promotion] : Promotion::Type[:discount]
        respond_to do |format|
            format.html # new.html.erb
            format.xml  { render :xml => @store }
        end
    end

    def create
        
        @promotion = Promotion.new(params[:promotion])
        @promotion.merchant_id = params[:merchant_id]
        respond_to do |format|
            if @promotion.save
                format.html { redirect_to(@promotion) }
                format.xml  { render :xml => @promotion, :status => :created, :location => @promotion }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @promotion.errors, :status => :unprocessable_entity }
            end
        end

    end

    def edit
        @promotion = Promotion.find(params[:id])

        if @promotion.merchant_id.nil?
            @promotion.merchant_id = @promotion.store.merchant_id
        end
    end

    def update
        @promotion = Promotion.find(params[:id])

        if @promotion.update_attributes(params[:promotion])
            redirect_to promotion_path(@promotion)
        else
            render :action => 'edit'
        end
    end

    def show
        @promotion = Promotion.find(params[:id])
    end

    def destroy
        @promotion = Promotion.find(params[:id])
        merchant = @promotion.merchant_id
        @promotion.destroy

        respond_to do |format|
            format.html { redirect_to(merchant_url(merchant)) }
            format.xml  { head :ok }
        end
    end

end
