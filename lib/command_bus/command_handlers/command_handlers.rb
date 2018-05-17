class CreateEmployeeCommandHandler

  def initialize(employee_repository)
    @employee_repository = employee_repository
  end

  def handle(command)
    new_employee = Employee.create(command.name, command.title, command.salary.to_i)
    @employee_repository.save new_employee
  end
end

class PromoteEmployeeCommandHandler
  def handle(command)
    @command = command
  end
end

class AllEmployeesQueryHandler
  def handle(query = nil)
    EmployeeView.all
  end
end

class EmployeesDetailsQueryHandler

  def handle(query)
    EmployeeView.find_by(uuid: query.employee_id)
  end
end
