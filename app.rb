ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'json'
require 'simple_event_sourcing'
require 'sqlite3'
require 'sinatra/activerecord'
require 'sinatra/json'

require './environment'

class MyApp < JsonApiApp
  include ServiceProvider::ContainerAware

  # def command_bus
  #   ServiceProvider::Container[:command_bus]
  # end

  get '/employee' do
    params.select! { |k| %i[title name salary].include? k }
    employees = if params.empty?
                  command_bus.call(AllEmployeesQuery.new)
                else
                  command_bus.call(FindEmployeesByParamsQuery.new(params))
                end
    halt 204 unless employees
    employees.to_json
  end

  post '/employee' do
    command_bus.call(CreateEmployeeCommand.new(params))
    { id: params['id'], name: params['name'], title: params['title'], salary: params['salary'].to_i }.to_json
  end

  get '/employee/:id' do
    employee = command_bus.call(EmployeesDetailsQuery.new(employee_id: params[:id]))
    halt 404 unless employee
    employee.to_json
  end
end
