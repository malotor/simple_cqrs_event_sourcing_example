require 'sinatra'
require 'json'

require_relative './model/employee'
require_relative './model/employee_repository'

class MyApp < Sinatra::Base
  get "/" do
    content_type :json
    { :foo => 'bar' }.to_json
  end

  get "/employee" do
    content_type :json
    result = []
    result << Employee.create('Fred Flintstone', 'Crane Operator', 30000)
    puts result.to_json
    result.to_json
  end

end
