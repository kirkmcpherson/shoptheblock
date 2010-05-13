class PromoCodesController < ApplicationController
    before_filter :requires_administrator_role

    def index
        @promo_codes = PromoCode.active
        @expired_promo_codes = PromoCode.expired
    end

    def new
        @promo_code = PromoCode.new
    end

    def create
        @promo_code = PromoCode.new(params[:promo_code])
        respond_to do |format|
            if @promo_code.save
                format.html { redirect_to promo_codes_path }
                format.xml  { render :xml => @promo_code, :status => :created, :location => @promo_code }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @promo_code.errors, :status => :unprocessable_entity }
            end
        end
    end

    def edit
        @promo_code = PromoCode.find(params[:id])
    end

    def update
        @promo_code = PromoCode.find(params[:id])

        if @promo_code.update_attributes(params[:promo_code])
            redirect_to promo_codes_path
        else
            render :action => 'edit'
        end
    end

    def destroy
        @promo_code = PromoCode.find(params[:id])
        @promo_code.destroy

        respond_to do |format|
            format.html { redirect_to(promo_codes_path) }
            format.xml  { head :ok }
        end
    end

end
