ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'json'
require 'simple_event_sourcing'
require 'sqlite3'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'bundler/setup'

Bundler.require(:default, Sinatra::Application.environment)

require 'arkency/command_bus'
require 'arkency/command_bus/alias'

require_relative './model/employee/employee_events'
require_relative './model/employee/employee_event_subscribers'
require_relative './model/employee/employee'
require_relative './model/employee/employee_repository'
require_relative './model/employee_view'
#
require_relative './lib/service_provider'


require_relative './lib/command_bus/commands'
require_relative './lib/command_bus/command_handlers'
require_relative './lib/command_bus/querys'
require_relative './lib/command_bus/query_handlers'

require_relative './lib/elasticsearch/employee_client'

require_relative './lib/projections/projection'

Dir["#{File.dirname(__FILE__)}/lib/projections/*_projection.rb"].each {|file| require file }

require_relative './lib/base_controller'

Dir["#{File.dirname(__FILE__)}/app/controllers/**/*_controller.rb"].each {|file| require file }

require_relative './lib/json_api_app'

configure do
  enable :logging
  # Log
  Dir.mkdir('log') unless File.exist?('log')
  logger = File.new("log/#{settings.environment}.log", 'a+')
  logger.sync = true

  use Rack::CommonLogger, logger
  ServiceProvider::Container[:log] = Logger.new(logger)
end

# Environment configuration
configure :development, :production do
  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    config.host = 'redis'
  end
end

configure :test do
  SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
    # config.mock = true
    config.host = 'redis'
  end
end

# Register services

ServiceProvider::Container[:redis_client] = SimpleEventSourcing::Events::EventStore::RedisClient.get_client

ServiceProvider::Container[:employee_repository] = EmployeeRepository.new(
  SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
    ServiceProvider::Container[:redis_client]
  )
)

# Event dispatcher
SimpleEventSourcing::Events::EventDispatcher.add_subscriber(ProjectorEmployeeEventSubscriber.new)

# Command buss
ServiceProvider::Container[:command_bus] = CommandBus.new
bus = ServiceProvider::Container[:command_bus]
bus.register(CreateEmployeeCommand, lambda { |command|
                                      CreateEmployeeCommandHandler.new(ServiceProvider::Container[:employee_repository]).handle(command)
                                    })
bus.register(AllEmployeesQuery, lambda { |query|
                                  AllEmployeesQueryHandler.new.handle(query)
                                })
bus.register(EmployeesDetailsQuery, lambda { |query|
                                      EmployeesDetailsQueryHandler.new.handle(query)
                                    })
bus.register(FindEmployeesByParamsQuery, lambda { |query|
                                           FindEmployeesByParamsQueryHandler.new.handle(query)
                                         })

# Elasticsearch Client
elasticsearch_client = Elasticsearch::Client.new url: 'http://elasticsearch:9200', log: true, trace: true, logger: ServiceProvider::Container[:log], tracer: ServiceProvider::Container[:log]
ServiceProvider::Container[:elasticsearch] = EmployeeClient.new(elasticsearch_client)
ServiceProvider::Container[:elasticsearch].client.transport.reload_connections!
ServiceProvider::Container[:elasticsearch].client.cluster.health

# Projections

Projector.register([
  DbProjection.new,
  ElasticsearchProjection.new
])
