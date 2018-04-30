require_relative './model/employee'
require_relative './model/employee_repository'


SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
 config.host = 'redis'
end

# RedisClient.configure do |config|
#   config.mock = true
# end

employee_repository = EmployeeRepository.new(
  SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
    SimpleEventSourcing::Events::EventStore::RedisClient.get_client
  )
)

SimpleEventSourcing::Events::EventDispatcher.add_subscriber(WelcomeEmployeeSubscriber.new)
SimpleEventSourcing::Events::EventDispatcher.add_subscriber(CongratulateEmployeeSubscriber.new)

fred = Employee.create("Fred Flintstone","Crane Operator",30000.0)
fred.salary=35000.0
employee_repository.save fred

barney = Employee.create("Barney Rubble","Crane Operator",10000.0)
employee_repository.save barney

new_fred = employee_repository.findById fred.aggregate_id.to_s

puts "Name: #{new_fred.name}"
puts "Title: #{new_fred.title}"
puts "Salary: #{new_fred.salary}"

new_barney = employee_repository.findById barney.aggregate_id.to_s

puts "Name: #{new_barney.name}"
puts "Title: #{new_barney.title}"
puts "Salary: #{new_barney.salary}"
