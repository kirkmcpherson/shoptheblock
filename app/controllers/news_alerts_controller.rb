class NewsAlertsController < ApplicationController

  def index
    @news_alerts = NewsAlert.find(:all, :order => "created_at DESC")
  end

  def show
    @news_alert = NewsAlert.find(params[:id])
  end

  def destroy
    @news_alert = NewsAlert.find(params[:id])
    @news_alert.destroy

    respond_to do |format|
      format.html { redirect_to(news_alerts_url) }
      format.xml { head :ok }
    end
  end

  def show_latest
    @news_alert = NewsAlert.last
  end
end
