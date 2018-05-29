class CreateEmployeeCommand
  attr_accessor :id, :name, :title, :salary
  def initialize(args)
    @id = args[:id]
    @name = args[:name]
    @title = args[:title]
    @salary = args[:salary]
  end
end

class PromoteEmployeeCommand
  attr_accessor :employee_id, :new_salary
  def initialize(args)
    @employee_id = args[:employee_id]
    @new_salary = args[:new_salary]
  end
end
