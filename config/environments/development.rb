# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

begin
  GOOGLE_API_KEY = File.open('config/google_maps_api_key.txt').read
rescue => e
  raise 'No Google Maps API key found. Create a file named google_maps_api_key in config/ with just the API key in it. You can get one from http://code.google.com/apis/maps/signup.html'
end

Paperclip.options[:image_magick_path] = "/opt/local/bin"

config.to_prepare do
    BillingHelper::Config.gateway = :braintree
    BillingHelper::Config.test_mode
    BillingHelper::Config.braintree_credentials('btdemo', 'btdemo1234')

end

# Sandbox username: ddrew@brightspark3.com
# Sandbox password: brightspark
PAYPAL_INBOUND_URL="http://toronto.brightspark.com:3032"
PAYPAL_TOKEN="Ex1Rj0rgLX2aQhFoOVFUykdtXhMSRiG75ay3JJ4JKlhMCYc4mEHCY0NU-du"
PAYPAL_EMAIL = "kirk.m_1273075958_biz@gmail.com"
#PAYPAL_CERT_ID = "ZK4MGBCJHDF32"
PAYPAL_CERT_ID = "MN7CHLTTW383G"
PAYPAL_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
PAYPAL_CERT = "paypal_sandbox_cert.pem"

# Don't care if the mailer can't send
#config.action_mailer.raise_delivery_errors = false
#config.action_mailer.delivery_method = :test

config.action_mailer.default_url_options = { :host => "shoptheblock.dyndns.org:3000" }
config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :smtp

ActionController::Base.asset_host = 'http://shoptheblock.dyndns.org:3000'

if File.exists?(File.join(RAILS_ROOT,'tmp', 'debug.txt'))
  require 'ruby-debug'
  Debugger.wait_connection = true
  Debugger.start_remote
  File.delete(File.join(RAILS_ROOT,'tmp', 'debug.txt'))
end
