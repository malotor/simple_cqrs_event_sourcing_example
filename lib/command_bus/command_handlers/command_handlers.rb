class CreateEmployeeCommandHandler
  def initialize(employee_repository)
    @employee_repository = employee_repository
  end

  def handle(command)
    new_employee = Employee.create(command.id, command.name, command.title, command.salary.to_i)
    @employee_repository.save new_employee
  end
end

class PromoteEmployeeCommandHandler
  def handle(command)
    @command = command
  end
end

class AllEmployeesQueryHandler
  def handle(_query = nil)
    EmployeeView.all
  end
end

class EmployeesDetailsQueryHandler
  def handle(query)
    EmployeeView.find_by(uuid: query.employee_id)
  end
end

class FindEmployeesByParamsQueryHandler
  def handle(query)
    client = ServiceProvider::Container[:elasticsearch]

    log = ServiceProvider::Container[:log]
    log.debug query.params.inspect

    #response = client.search index: 'employee', body: { query: { match: { name: query.params[:name] } } }
    response = client.search query.params
    log.debug response.inspect
    result = []
    response['hits']['hits'].each do |s|
      result << s['_source']
    end
    result
  end
end
