ActionController::Routing::Routes.draw do |map|

    map.welcome         '/home',            :controller => 'home', :action => 'welcome'
    map.neighbourhood   '/neighbourhood',   :controller => "home", :action => "neighbourhood"
    map.account         '/account',         :controller => 'users', :action => 'view'
    map.login           '/login',           :controller => 'sessions', :action => 'new'
    map.logout          '/logout',          :controller => 'sessions', :action => 'destroy'
    map.activate        '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
    map.company_info    '/companyinfo',     :controller => 'home', :action => 'company_info'
    map.how_it_works    '/how_it_works',    :controller => 'home', :action => 'how_it_works'
    map.faq             '/faq',             :controller => 'home', :action => 'faq'
    map.signup          '/signup',          :controller => 'users', :action => 'new'
    map.contact         '/contact',         :controller => 'home', :action => 'contact'
    map.participating_stores             '/participating_stores',             :controller => 'home', :action => 'participating_stores'
    map.myneighbourhood             '/myneighbourhood',             :controller => 'home', :action => 'participating_stores_neighbourhood'
    map.news             '/news',           :controller => 'home', :action => 'news'
    map.legal           '/legal',           :controller => 'home', :action => 'legal'
    map.privacy           '/privacy',       :controller => 'home', :action => 'privacy'
    map.support         '/support',         :controller => 'home', :action => 'support'
    map.blog            '/blog',            :controller => 'home', :action => 'blog'
    map.validate_address '/search/validate', :controller => 'home', :action => 'validate_address'
    map.tbd             '/tbd',             :controller => 'home', :action => 'tbd'
    map.neighbourhood_search '/search',     :controller => 'home', :action => 'neighbourhood_search', :method => :post
    map.temp_card       '/users/temp_card', :controller => 'users', :action => 'temp_card'
    map.temp_card_image '/users/temp_card_image', :controller => 'users', :action => 'temp_card_image'
    map.lost_card       '/users/lost_card/:code', :controller => 'users', :action => 'lost_card'
    map.pending_cards   '/admin/pending_cards', :controller => 'users', :action => 'pending_cards'
    map.consumer_info   '/consumerinfo',    :controller => 'home', :action => 'consumer_info'
    map.merchant_info   '/merchantfaq',     :controller => 'merchants', :action => 'faq'
    map.consumer_info   '/consumer_info',     :controller => 'home', :action => 'consumer_info'
    map.renew_user      '/users/renew',     :controller => 'users', :action => 'renew', :conditions => { :method => [:post, :get] }
    map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password', :conditions => { :method => [:post, :get] }
    map.reset_password  '/reset/:code',     :controller => 'users', :action => 'reset_password'
    map.send_news_alert '/admin/send_news_alert', :controller => 'users', :action => 'send_news_alert'
    map.edit_newsletter_recipients '/admin/newsletter_recipients', :controller => 'users', :action => 'edit_newsletter_recipients'
    map.unsubscribe     '/unsubscribe/:code', :controller => 'users', :action => 'unsubscribe', :code => nil
    map.verify_payment  '/verify/:code',    :controller => 'users', :action => 'verify_payment', :code => nil
    map.send_send_signup_email 'users/send_signup_email', :controller => 'users',:action => 'send_signup_email'

    map.expired '/expired', :controller => 'users', :action => 'expired'

    # just in case paypal hits the wrong URL
    map.verify_payment_incorrect  '/verify//:code',    :controller => 'users', :action => 'verify_payment', :code => nil

    map.return_from_paypal '/return/:code',       :controller => 'users', :action => 'return_from_paypal'
    map.return_from_paypal_gift '/return_gift/:code',       :controller => 'gifts', :action => 'return_from_paypal_gift'
    map.return_from_paypal_renewal '/return_renewal/:code',       :controller => 'users', :action => 'return_from_paypal_renewal'
    map.confirm_gift '/confirm_gift/:id', :controller => 'gifts', :action => 'edit'


    map.latest_news_alert '/latest_news_alert', :controller => 'news_alerts', :action => 'show_latest'
    map.root            :controller => 'home', :action => 'welcome'

    map.newsletter_wizard_details '/newsletter_wizard/details', :controller => 'newsletter_wizard', :action => 'details', :method => [:get, :post]
    map.newsletter_wizard_ads '/newsletter_wizard/ads', :controller => 'newsletter_wizard', :action => 'ads', :method => [:get, :post]
    map.newsletter_wizard_recipients '/newsletter_wizard/recipients', :controller => 'newsletter_wizard', :action => 'recipients', :method => [:get, :post]
    map.newsletter_wizard_last_step '/newsletter_wizard/last_step', :controller => 'newsletter_wizard', :action => 'last_step'
    map.newsletter_wizard_preview '/newsletter_wizard/preview', :controller => 'newsletter_wizard', :action => 'preview'
    map.newsletter_wizard_send_newsletter '/newsletter_wizard/send_newsletter', :controller => 'newsletter_wizard', :action => 'send_newsletter'
    map.newsletter_wizard_new_story '/newsletter_wizard/new_story', :controller => 'newsletter_wizard', :action => 'new_story'
    map.newsletter_wizard_new_ad '/newsletter_wizard/new_ad', :controller => 'newsletter_wizard', :action => 'new_ad'

    map.newsletter_wizard_save_without_sending '/newsletter_wizard/save_without_sending', :controller => 'newsletter_wizard', :action => 'save_without_sending'

    map.give_a_gift '/give_a_gift', :controller => 'gifts', :action => 'new'

    map.renew_membership '/renew_membership', :controller => 'users', :action => 'renew_membership', :method => [:get, :post]
    #map.renew_membership '/renew_membership', :controller => 'users', :action => 'renew_membership_verify', :method => [:post]
    map.renew '/renew', :controller => 'users', :action => 'renew', :method => [:get, :post]
    
    map.resources :users
    map.resource  :session
    map.resources :categories
    map.resources :news_alerts
    map.resources :news_items
    map.resources :newsletters
    map.resources :promo_codes
    map.resources :testimonials
    map.resources :press_releases
    map.resources :gifts

    map.resources :merchants, :shallow => true do |merchant|
        merchant.resources :stores
        merchant.resources :promotions
    end

    # The priority is based upon order of creation: first created -> highest priority.

    # Sample of regular route:
    #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   map.resources :products

    # Sample resource route with options:
    #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

    # Sample resource route with sub-resources:
    #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
    # Sample resource route with more complex sub-resources
    #   map.resources :products do |products|
    #     products.resources :comments
    #     products.resources :sales, :collection => { :recent => :get }
    #   end

    # Sample resource route within a namespace:
    #   map.namespace :admin do |admin|
    #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
    #     admin.resources :products
    #   end

    # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
    # map.root :controller => "welcome"

    # See how all your routes lay out with "rake routes"

    # Install the default routes as the lowest priority.
    # Note: These default routes make all actions in every controller accessible via GET requests. You should
    # consider removing the them or commenting them out if you're using named routes and resources.
    #map.connect ':controller/:action/:id'
    #map.connect ':controller/:action/:id.:format'
end
