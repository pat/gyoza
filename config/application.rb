require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Assets should be precompiled for production (so we don't need the gems loaded then)
Bundler.require(*Rails.groups(assets: %w(development test)))

module Gyoza
  class Application < Rails::Application
    require 'gyoza'

    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Melbourne'

    # config.i18n.default_locale = :de

    config.middleware.use OmniAuth::Builder do
      provider :github, ENV['GITHUB_APP_ID'], ENV['GITHUB_SECRET'],
        client_options: {
          site:          "#{Gyoza::GITHUB_HOST}/api/v3",
          authorize_url: "#{Gyoza::GITHUB_HOST}/login/oauth/authorize",
          token_url:     "#{Gyoza::GITHUB_HOST}/login/oauth/access_token"
        },
        scope: 'user:email'
    end
  end
end
