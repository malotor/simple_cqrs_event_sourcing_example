class CreateEmployeeCommand
  attr_accessor :name,:title,:salary
  def initialize(args)
    @name = args[:name]
    @title = args[:title]
    @salary = args[:salary]
  end

end

class PromoteEmployeeCommand
  attr_accessor :employee_id,:new_salary
  def initialize(args)
    @employee_id = args[:employee_id]
    @new_salary = args[:new_salary]
  end
end


class AllEmployeesQuery; end

class EmployeesDetailsQuery
  attr_accessor :employee_id
  def initialize(args)
    @employee_id = args[:employee_id]
  end
end
