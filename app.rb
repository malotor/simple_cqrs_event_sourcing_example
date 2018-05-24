
require './environment'

class MyApp < JsonApiApp
  include ServiceProvider::ContainerAware

  def filtered_params
    params.select { |k| %w[title name salary].include? k }
  end
  get '/employee' do
    log.debug '[PARAMS]' + filtered_params.inspect
    employees = if filtered_params.empty?
                  command_bus.call(AllEmployeesQuery.new)
                else
                  command_bus.call(FindEmployeesByParamsQuery.new(filtered_params))
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
