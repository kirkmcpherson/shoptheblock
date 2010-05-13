module NewslettersHelper

  def link_to_preview_newsletter id, text=nil
    link_to text || t('newsletters.preview'), newsletter_wizard_preview_path+"?newsletter_id=#{id}", :target => '_blank'
  end

end
