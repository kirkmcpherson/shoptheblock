class NewsletterWizardController < ApplicationController

  before_filter :requires_administrator_role, :except => [:preview]

  tiny_mce

  # page 1
  def details
    @new_newsletter_stories = []
    @newsletter_stories = []

    if request.get?
      if n_id = params[:newsletter_id]
        @newsletter = Newsletter.find(n_id)
        @newsletter_stories = @newsletter.stories
      else
        @newsletter = Newsletter.new
        @new_newsletter_stories << NewsletterStory.new(:position => 0)
      end
    elsif request.post?
      @newsletter = params[:newsletter_id].blank? ? Newsletter.new(params[:newsletter]) : Newsletter.find(params[:newsletter_id])

      # use a transaction to ensure everything gets saved only if
      # all validations on all stories and the newsletter itself succeed
      Newsletter.transaction do
        # when coming back to the details page, stories can be edited, added and deleted...

        # deleted stories
        NewsletterStory.delete(@newsletter.story_ids.map(&:to_s) - (params[:newsletter_stories] || {}).keys)

        # updates to existing stories
        (params[:newsletter_stories] || {}).each do |id, story|
          @newsletter_stories << (newsletter_story = @newsletter.stories.find(id))
          unless newsletter_story.update_attributes(story)
            render :action => :details
            raise ActiveRecord::Rollback
          end
        end

        # new stories
        params[:new_newsletter_stories].to_a.each do |story|
          @newsletter_stories << @newsletter.stories.build(story)
        end

        @newsletter_stories.sort! { |a, b| a.position <=> b.position }

        @newsletter.attributes = params[:newsletter]
        if @newsletter.save
          redirect_to :action => :ads, :newsletter_id => @newsletter.id
        else
          render :action => :details
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  # page 2
  def ads
    @newsletter = Newsletter.find(params[:newsletter_id])
    @newsletter_ads = []
    @new_newsletter_ads = []
    @merchants = Merchant.all(:order => 'merchants.name')
    if request.get?
      @newsletter_ads = @newsletter.ads
    elsif request.post?
      # use a transaction to ensure everything gets saved only if
      # all validations on all ads succeed
      Newsletter.transaction do
        # when coming back to the ads page, ads can be edited, added and deleted...

        # deleted ads
        NewsletterAd.delete(@newsletter.ad_ids.map(&:to_s) - (params[:newsletter_ads] || {}).keys)

        # updates to existing ads
        (params[:newsletter_ads] || {}).each do |id, ad|
          @newsletter_ads << (newsletter_ad = @newsletter.ads.find(id))
          unless newsletter_ad.update_attributes(ad)
            render :action => :ads
            raise ActiveRecord::Rollback
          end
        end

        # new ads
        params[:new_newsletter_ads].to_a.each do |ad|
          @newsletter_ads << @newsletter.ads.build(ad)
        end

        @newsletter_ads.sort! { |a, b| a.position <=> b.position }

        @newsletter.newsletter_stores.destroy_all
        @newsletter.add_stores(params[:stores])

        if @newsletter.save
          if params[:commit] == 'Next'
            redirect_to :action => :recipients, :newsletter_id => @newsletter.id
          elsif params[:commit] == 'Back'
            redirect_to :action => :details, :newsletter_id => @newsletter.id
          end
        else
          render :action => :ads, :newsletter_id => @newsletter.id
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  # page 3
  def recipients
    @newsletter = Newsletter.find(params[:newsletter_id], :include => :categories)
    if request.get?
      @categories = Category.all(:order => 'categories.name ASC')
      @members = User.active_members
      @non_members = User.non_member_newsletter_recipients
    elsif request.post?
      @newsletter.update_attribute :recipient_method, params[:recipients]
      if @newsletter.recipient_method == Newsletter::RECIPIENTS_BY_CATEGORY
        @newsletter.newsletter_categories.destroy_all
        @newsletter.add_categories(params[:categories])
      elsif @newsletter.recipient_method == Newsletter::SELECT_RECIPIENTS
        @newsletter.newsletter_recipients.destroy_all
        @newsletter.add_recipients(params[:subscribers])
      end
      if params[:commit] == 'Next'
        redirect_to :action => :last_step, :newsletter_id => @newsletter.id
      elsif params[:commit] == 'Back'
        redirect_to :action => :ads, :newsletter_id => @newsletter.id
      end
    end
  end

  # page 4
  def last_step
    @newsletter = Newsletter.find(params[:newsletter_id])
    @recipients = t('newsletter_wizard.last_step.all')
    case @newsletter.recipient_method
      when Newsletter::RECIPIENTS_BY_CATEGORY
        @recipients = t('newsletter_wizard.last_step.categories', :categories => @newsletter.categories.join(', '))
      when Newsletter::SELECT_RECIPIENTS
        @recipients = @newsletter.users.collect(&:full_name_and_email) * ', '
    end
  end

  def save_without_sending
    @newsletter = Newsletter.find(params[:newsletter_id])

    @recipients = t('newsletter_wizard.last_step.all')
    case @newsletter.recipient_method
      when Newsletter::RECIPIENTS_BY_CATEGORY
        @recipients = t('newsletter_wizard.last_step.categories', :categories => @newsletter.categories.join(', '))
      when Newsletter::SELECT_RECIPIENTS
        @recipients = @newsletter.users.collect(&:full_name_and_email) * ', '
    end

    if @newsletter.update_attributes(params[:newsletter])
      flash[:notice] = t('newsletter_wizard.last_step.save_success')
    else
      flash[:error] = t('newsletter_wizard.last_step.save_failed')
    end
    render :last_step
  end

  def preview
    @newsletter = Newsletter.find(params[:newsletter_id])
    @preview = UserMailer.create_newsletter(@newsletter, User.new(:email_format => User::EmailFormat[:html])).parts.last
    render :template => '/newsletter_wizard/preview', :layout => false
  end

  def send_newsletter
    @newsletter = Newsletter.find(params[:newsletter_id])
    @newsletter.recipients.each do |recipient|
      begin
        UserMailer.deliver_newsletter(@newsletter, recipient)
      rescue => e
        logger.error e
      end
    end
    flash[:notice] = t('newsletter_wizard.send.flash', :volume => @newsletter.volume, :issue => @newsletter.issue)
    redirect_to account_path
  end

  def new_story
    render :update do |page|
      page << "tinyMCE.triggerSave();"
      page << "var positionField = lastNewsletterItemPositionField();"
      page << "var nextPosition = positionField ? parseInt(lastNewsletterItemPositionField().value) + 1 : 0;"
      page['newsletter_details_form'].insert render(:partial => 'newsletter_story', :locals => { :ns => NewsletterStory.new })
      page << "lastNewsletterItemPositionField().value = nextPosition;"
      page << "tinyMCE.init(tinyMCE.activeEditor.settings);"
      page << "disableMoveNewsletterItemLinks();"
    end
  end

  def new_ad
    render :update do |page|
      page << "var positionField = lastNewsletterItemPositionField();"
      page << "var nextPosition = positionField ? parseInt(lastNewsletterItemPositionField().value) + 1 : 0;"
      page['newsletter_ads_form'].insert render(:partial => 'newsletter_ad', :locals => { :na => NewsletterAd.new(:newsletter_id => params[:newsletter_id]) })
      page << "lastNewsletterItemPositionField().value = nextPosition;"
      page << "disableMoveNewsletterItemLinks();"
    end
  end

end
