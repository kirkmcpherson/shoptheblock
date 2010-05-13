class NewslettersController < ApplicationController

  before_filter :requires_administrator_role
  
  def index
    @newsletters = Newsletter.all(:order => 'newsletters.publication_date DESC')
  end

  def destroy
    @newsletter = Newsletter.find(params[:id])
    if @newsletter.destroy
      flash[:notice] = t('newsletters.index.delete.flash_success')
    else
      flash[:error] = t('newsletters.index.delete.flash_error')
    end
    redirect_to newsletters_path
  end

end
