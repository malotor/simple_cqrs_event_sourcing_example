require 'sqlite3'
require_relative './model/employee'
require_relative './model/employee_repository'
require_relative './model/employee_view'
require_relative './model/employee_view_repository'

SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
  config.host = 'redis'
end

# RedisClient.configure do |config|
#   config.mock = true
# end


#!/usr/bin/ruby
begin

    db = SQLite3::Database.open "employee.db"
    puts db.get_first_value 'SELECT SQLITE_VERSION()'

rescue SQLite3::Exception => e

    puts "Exception occurred"
    puts e

ensure
    db.close if db
end

employee_view_repository = EmployeeViewRepository.new(db)

employee_repository = EmployeeRepository.new(
  SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
    SimpleEventSourcing::Events::EventStore::RedisClient.get_client
  )
)

SimpleEventSourcing::Events::EventDispatcher.add_subscriber(WelcomeEmployeeSubscriber.new)
SimpleEventSourcing::Events::EventDispatcher.add_subscriber(CongratulateEmployeeSubscriber.new)

fred = Employee.create('Fred Flintstone', 'Crane Operator', 30_000.0)
fred.salary = 35_000.0
employee_repository.save fred

barney = Employee.create('Barney Rubble', 'Crane Operator', 10_000.0)
employee_repository.save barney

new_fred = employee_repository.findById fred.aggregate_id.to_s

puts "Name: #{new_fred.name}"
puts "Title: #{new_fred.title}"
puts "Salary: #{new_fred.salary}"

new_barney = employee_repository.findById barney.aggregate_id.to_s

puts "Name: #{new_barney.name}"
puts "Title: #{new_barney.title}"
puts "Salary: #{new_barney.salary}"
