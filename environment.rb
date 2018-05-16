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


Dir.mkdir("log") unless File.exist?("log")
logger = File.new("log/#{settings.environment}.log", 'a+')
logger.sync = true

configure do
  use Rack::CommonLogger, logger
end

configure :development, :production do

  #set :database, { adapter: "sqlite3", database: "foo.sqlite3" }

  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    config.host = 'redis'
  end
end

configure :test do

  #set :database, { adapter: "sqlite3", database: "foo.sqlite3" }

  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    config.mock = true
  end

end
# configure do
#   # logging is enabled by default in classic style applications,
#   # so `enable :logging` is not needed
#   Dir.mkdir("log") unless File.exist?("log")
#   file = File.new("log/#{settings.environment}.log", 'a+')
#   file.sync = true
#   use Rack::CommonLogger, file
# end

# if ENV['RACK_ENV'] == 'test'
#   #set :database, { adapter: "sqlite3", database: "foo.sqlite3" }
#   SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
#     config.mock = true
#   end
# else
#   #set :database, { adapter: "sqlite3", database: "foo.sqlite3" }
#
# end

# configure :production, :test do
#   ...
# end
