require 'sinatra'
require 'json'

require 'sqlite3'
require 'active_record'

require_relative './model/employee'
require_relative './model/employee_repository'

# Set up a database that resides in RAM
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

class MyApp < Sinatra::Base
  get '/' do
    content_type :json
    { foo: 'bar' }.to_json
  end

  get '/employee' do
    content_type :json
    result = []
    result << Employee.create('Fred Flintstone', 'Crane Operator', 30_000)
    result.to_json
  end
end
