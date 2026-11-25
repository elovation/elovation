# frozen_string_literal: true

require 'active_support/testing/time_helpers'

# bin/screenshots sets SCREENSHOT_TIME so pages say "3 days ago" and charts
# show the same dates whichever day the screenshots are captured. It freezes
# the clock for the development server only (db/seeds.rb reads it directly).
if Rails.env.development? && defined?(Rails::Server) && ENV['SCREENSHOT_TIME']
  # Migrations dated after the frozen time would otherwise be rejected.
  Rails.application.config.active_record.validate_migration_timestamps = false

  Rails.application.config.after_initialize do
    Class.new { include ActiveSupport::Testing::TimeHelpers }.new.travel_to(Time.zone.parse(ENV['SCREENSHOT_TIME']))
  end
end
