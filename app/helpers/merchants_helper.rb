module MerchantsHelper

  def link_to_merchant_web_site(merchant)

    link_to(merchant.web_site, merchant.web_site_url, :target => '_blank')

  end


end
