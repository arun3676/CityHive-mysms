# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

RSpec.configure do |config|
  # Mongoid replaces ActiveRecord in this app.
  config.use_active_record = false

  # Infer spec type (:request, :model, ...) from the file's directory, so we
  # don't have to tag every example with `type: :request`.
  config.infer_spec_type_from_file_location!

  # Mongoid has no transactional fixtures; wipe the test database before each
  # example so specs are isolated. (test env points at the `mysms_test` db.)
  config.before(:each) { Mongoid.purge! }

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
