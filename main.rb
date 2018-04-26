require_relative './model/employee'
require_relative './lib/redis_event_store'

# RedisEventStore.configure do |config|
#   config.host = 'redis'
# end

RedisEventStore.configure do |config|
  config.client = RedisEventStore::RedisMock.new
end

SimpleEventSourcing::Events::EventDispatcher.add_subscriber(WelcomeEmployeeSubscriber.new)
SimpleEventSourcing::Events::EventDispatcher.add_subscriber(CongratulateEmployeeSubscriber.new)

fred = Employee.new(name: "Fred Flintstone", title: "Crane Operator", salary: 30000.0)
fred.salary=35000.0
fred.save
puts "Fred new salary: #{fred.salary}"

fred_id = fred.aggregate_id

barney = Employee.new(name:"Barney Rubble", title:  "Crane Operator",  salary: 10000.0)
barney.save

client = RedisEventStore::Client.new
history = client.get_history fred_id
history.inspect

new_fred = Employee.create_from_history history
new_fred.inspect
puts "Name: #{new_fred.name}"
puts "Title: #{new_fred.title}"
puts "Salary: #{new_fred.salary}"
