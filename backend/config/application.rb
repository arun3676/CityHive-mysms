require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.middleware.use ActionDispatch::Cookies

    session_options = { key: "_mysms_session" }
    if Rails.env.production?
      session_options[:same_site] = :none
      session_options[:secure] = true
    else
      session_options[:same_site] = :lax
    end
    config.middleware.use ActionDispatch::Session::CookieStore, **session_options
  end
end
