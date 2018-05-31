
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
  RedisClient.configure do |config|
    config.host = 'redis'
  end
end

configure :test do
  RedisClient.configure do |config|
    # config.mock = true
    config.host = 'redis'
  end
end

# Register services

ServiceProvider::Container[:redis_client] = RedisClient.get_client

ServiceProvider::Container[:employee_repository] = EmployeeRepository.new(
  EventStore::RedisEventStore.new(
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
#elasticsearch_client.reload_connections!
#elasticsearch_client.cluster.health

ServiceProvider::Container[:elasticsearch] = elasticsearch_client

# Projections

Projector.register([
  DbProjection.new,
  ElasticsearchProjection.new
])
