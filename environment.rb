require "bundler/setup"

Bundler.require(:default, Sinatra::Application.environment)

# module Logging
#
#   # This is the magical bit that gets mixed into your classes
#   def logger
#     Logging.logger
#   end
#
#   d
#   # Global, memoized, lazy initialized instance of a logger
#   def self.logger
#
#     Dir.mkdir("log") unless File.exist?("log")
#     logger = File.new("log/#{settings.environment}.log", 'a+')
#     logger.sync = true
#
#     @logger ||= logger
#   end
# end

#logger = Logger.new(STDOUT)



# Log
Dir.mkdir("log") unless File.exist?("log")
logger = File.new("log/#{settings.environment}.log", 'a+')
logger.sync = true


ServiceProvider::Container[:log] = Logger.new(STDOUT)

configure do
  use Rack::CommonLogger, ServiceProvider::Container[:log]
end

# Environment configuration
configure :development, :production do
  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    config.host = 'redis'
  end
end

configure :test do
  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    config.mock = true
  end
end

# Register services

ServiceProvider::Container[:redis_client] = SimpleEventSourcing::Events::EventStore::RedisClient.get_client

ServiceProvider::Container[:employee_repository] = EmployeeRepository.new(
  SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
    ServiceProvider::Container[:redis_client]
  )
)
