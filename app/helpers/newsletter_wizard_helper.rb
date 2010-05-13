module NewsletterWizardHelper

  def link_to_remove_item type
    link_to_function t('newsletter_wizard.items.remove'),
                     "if (confirm('#{t('newsletter_wizard.items.remove_confirm')}')) { " +
                     "  $(this).up('div.newsletter_item_container').remove(); " +
                     "  disableMoveNewsletterItemLinks();" +
                     "}",
                     :class    => 'newsletter_item_link',
                     :tabindex => -1
  end

  def move_item_link direction
    link_to_function t("newsletter_wizard.items.move_#{direction}"),
                     "moveNewsletterItem($(this).up('div.newsletter_item_container'), '#{direction}')",
                     :class    => "newsletter_item_link move_#{direction}",
                     :tabindex => -1
  end

  # renders a file chooser and if the field is already populated with an image, renders
  # a preview of the image with a 'remove' link
  def image_field form, object, name
    concat form.file_field(name)
    if object.send(name).exists?
      delete_field_id = "delete_#{object.id}_#{name}"
      concat hidden_field_tag("#{object.class.name.underscore.pluralize}[#{object.id}][delete_#{name}]", nil, :id => delete_field_id)
      concat(
        content_tag(:div, :class => 'newsletter_image_preview') do
          concat image_tag(object.send(name).url)
          concat ' '
          concat link_to_function(t('newsletter_wizard.items.remove'),
                                  "$(this).up('div.newsletter_image_preview').remove(); $('#{delete_field_id}').value = true",
                                  :tabindex => -1)
        end
      )
    end
  end

  def sidebar current_page
    content_for :sidebar_right do
      content_tag :ol do
        sidebar_item(:details, current_page) + sidebar_item(:ads, current_page) + sidebar_item(:recipients, current_page) + sidebar_item(:last_step, current_page)
      end
    end
  end

  def sidebar_item name, current_page
    content_tag :li, t("newsletter_wizard.sidebar.#{name}"), :class => (current_page == name ? 'current_wizard_page' : '')
  end

end
