# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
if Rails.env.development?
  console = ActiveSupport::Logger.new($stdout)
  console.formatter = Rails.logger.formatter
  console.level = Rails.logger.level

  Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
end
run Rails.application
