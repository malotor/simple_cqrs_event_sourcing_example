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

  get '/' do
    { foo: 'bar' }.to_json
  end

  get '/employee' do
    employees = EmployeeView.all
    halt 204 unless employees
    employees.to_json
  end

  post '/employee' do
    #new_employee = Employee.create(params['name'], params['title'], params['salary'].to_i)
    #employee_repository.save new_employee
    ServiceProvider::Container[:command_bus].(CreateEmployeeCommand.new(params))
    {name: params['name'], title: params['title'], salary: params['salary'].to_i}.to_json
  end

  get '/employee/:id' do
    employee = employee_repository.findById(params[:id])
    halt 404 unless employee
    employee.to_json
  end


end
