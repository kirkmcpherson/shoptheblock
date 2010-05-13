class PressReleasesController < ApplicationController

  before_filter :requires_administrator_role, :except => [ 'index','show' ]

  def index
    @press_releases = PressRelease.all :order => 'publication_date  DESC'     
  end

  def new
    @press_release = PressRelease.new
  end

  def create
    @press_release = PressRelease.new(params[:press_release])
    if @press_release.save
      redirect_to press_releases_path
    else
      render :action => "new"
    end
  end

  def edit
    @press_release = PressRelease.find(params[:id])
  end

  def update
    @press_release = PressRelease.find(params[:id])

    if @press_release.update_attributes(params[:press_release])
      redirect_to press_releases_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @press_release = PressRelease.find(params[:id])
    @press_release.destroy
    redirect_to(press_releases_path) 
  end

  def show
   @press_release = PressRelease.find params[:id]
  end

end
