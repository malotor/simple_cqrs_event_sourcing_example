require 'bundler/setup'

Bundler.require(:default, Sinatra::Application.environment)

require_relative './model/employee'
require_relative './model/employee_repository'
require_relative './model/employee_view'

require_relative './lib/service_provider'
require_relative './lib/json_api_app'
require_relative './lib/command_bus/commands/commands'
require_relative './lib/command_bus/command_handlers/command_handlers'

require 'arkency/command_bus'
require 'arkency/command_bus/alias'

require_relative './lib/elasticsearch/employee_client'


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
    #config.mock = true
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
SimpleEventSourcing::Events::EventDispatcher.add_subscriber(ProjectorElasticEmployeeEventSubscribe.new)


# Command buss
ServiceProvider::Container[:command_bus] = CommandBus.new
ServiceProvider::Container[:command_bus].register(CreateEmployeeCommand, lambda { |command|
                                                                           CreateEmployeeCommandHandler.new(ServiceProvider::Container[:employee_repository]).handle(command)
                                                                         })
ServiceProvider::Container[:command_bus].register(AllEmployeesQuery, lambda { |query|
                                                                       AllEmployeesQueryHandler.new.handle(query)
                                                                     })
ServiceProvider::Container[:command_bus].register(EmployeesDetailsQuery, lambda { |query|
                                                                           EmployeesDetailsQueryHandler.new.handle(query)
                                                                         })

ServiceProvider::Container[:command_bus].register(FindEmployeesByParamsQuery, lambda { |query|
                                                                                FindEmployeesByParamsQueryHandler.new.handle(query)
                                                                              })

# Elasticsearch Client
elasticsearch_client = Elasticsearch::Client.new url: 'http://elasticsearch:9200', log: true
ServiceProvider::Container[:elasticsearch] = EmployeeClient.new(elasticsearch_client)
ServiceProvider::Container[:elasticsearch].client.transport.reload_connections!
ServiceProvider::Container[:elasticsearch].client.cluster.health



# client.transport.reload_connections!
# client.cluster.health
