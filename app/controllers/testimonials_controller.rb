class TestimonialsController < ApplicationController

  before_filter :requires_administrator_role, :except => ['index', 'show']

  def index
    @testimonials = Testimonial.all
  end

  def new
    @testimonial = Testimonial.new
  end

  def create
    @testimonial = Testimonial.new(params[:testimonial])
    if @testimonial.save
      redirect_to testimonials_path
    else
      render :action => "new"
    end
  end

  def edit
    @testimonial = Testimonial.find(params[:id])
  end

  def update
    @testimonial = Testimonial.find(params[:id])

    if @testimonial.update_attributes(params[:testimonial])
      redirect_to testimonials_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @testimonial = Testimonial.find(params[:id])
    @testimonial.destroy
    redirect_to(testimonials_path) 
  end

  def show
    @testimonial = Testimonial.find(params[:id])
  end

end
