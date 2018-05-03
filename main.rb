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

<<<<<<< 28075cfb85c4933238397199da9c3c3b59755a1c
fred = Employee.create("Fred Flintstone","Crane Operator",30000.0)
fred.salary=35000.0
employee_repository.save fred

barney = Employee.create("Barney Rubble","Crane Operator",10000.0)
=======
fred = Employee.create('Fred Flintstone', 'Crane Operator', 30_000.0)
fred.salary = 35_000.0
employee_repository.save fred

barney = Employee.new('Barney Rubble', 'Crane Operator', 10_000.0)
>>>>>>> Adapt to version 1.0.0
employee_repository.save barney

new_fred = employee_repository.findById fred.aggregate_id.to_s

puts "Name: #{new_fred.name}"
puts "Title: #{new_fred.title}"
puts "Salary: #{new_fred.salary}"

new_barney = employee_repository.findById barney.aggregate_id.to_s

puts "Name: #{new_barney.name}"
puts "Title: #{new_barney.title}"
puts "Salary: #{new_barney.salary}"
