require_relative 'boot'

require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "skylight/docs"

module Dummy
  class Application < Rails::Application
    config.consider_all_requests_local = true
    config.show_errors = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
