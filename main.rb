require_relative './model/employee'
require_relative './lib/redis_event_store'

RedisEventStore.configure do |config|
  config.host = 'redis'
end

SimpleEventSourcing::Events::EventDispatcher.add_subscriber(CongratulateEmployeeSubscriber.new)

fred = Employee.new(name: "Fred Flintstone", title: "Crane Operator", salary: 30000.0)
fred.add_raise 5000.0
fred.save

barney = Employee.new(name:"Barney Rubble", title:  "Crane Operator",  salary: 10000.0)
barney.save
