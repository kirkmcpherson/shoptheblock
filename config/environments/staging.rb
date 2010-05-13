config.cache_classes = true

# Enable threaded mode
# config.threadsafe!

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

##GOOGLE_API_KEY='ABQIAAAAhJoY8NQDNMWsyUNRw09JXBTFxfLvlH3e5BMyzQNJbpeIqek33RSBha3e2mnRonjj-2lMb66szOzN_A' # shoptheblock.dyndns.org
GOOGLE_API_KEY='ABQIAAAAAYxxozw3UReLikOmUfUktRTCkOmdLSyBnfZTVoh7uv6cizgH6RTZ62uTNhNI-uu36Sb0QouptsDW3Q' # brightsparkstudios.ca

BillingHelper::Config.gateway = :braintree
BillingHelper::Config.braintree_credentials('btdemo', 'btdemo1234')

PAYPAL_EMAIL = "shopth_1239911868_biz@brightspark3.com"
PAYPAL_CERT_ID = "BMGJQX72E324N"
PAYPAL_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
PAYPAL_CERT = "paypal_sandbox_cert.pem"


config.action_mailer.default_url_options = { :host => "shoptheblock.brightsparkstudios.ca" }

#ActionController::Base.asset_host = 'http://shoptheblock.dyndns.org'
ActionController::Base.asset_host = 'http://shoptheblock.brightsparkstudios.ca'
