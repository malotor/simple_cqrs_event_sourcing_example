require 'sinatra'
require 'json'
require 'simple_event_sourcing'
require 'sqlite3'
require 'sinatra/activerecord'
require 'sinatra/json'

require_relative './model/employee'
require_relative './model/employee_repository'
require_relative './model/employee_view'
require './environment'

require_relative './lib/json_api_app'

SimpleEventSourcing::Events::EventDispatcher.add_subscriber(ProjectorEmployeeEventSubscriber.new)
#SimpleEventSourcing::Events::EventDispatcher.add_subscriber(CongratulateEmployeeSubscriber.new)

class MyApp < JsonApiApp

  def employee_repository
      @employee_repository ||= EmployeeRepository.new(
        SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
          SimpleEventSourcing::Events::EventStore::RedisClient.get_client
        )
      )
  end

  get '/' do
    { foo: 'bar' }.to_json
  end

  get '/employee' do
    @employees = EmployeeView.all
    @employees.to_json
  end

  post '/employee' do
    new_employee = Employee.create(params['name'], params['title'], params['salary'].to_i)
    employee_repository.save new_employee
    result = []
    result << new_employee
    result.to_json
  end

  get '/employee/:id' do
    employee = employee_repository.findById(params[:id])
    result = []
    result << employee
    result.to_json
  end


end
