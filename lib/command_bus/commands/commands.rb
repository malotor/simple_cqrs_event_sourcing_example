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
end


class AllEmployeesQuery; end

class EmployeesDetailsQuery
  attr_accessor :employee_id
end
