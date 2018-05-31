class AllEmployeesQuery;
  attr_accessor :page,:offset
  def initialize(page,offset)
    @page = page
    @offset = offset
  end
end

class FindEmployeesByParamsQuery
  attr_accessor :params
  def initialize(params)
    @params = params
  end
end

class EmployeesDetailsQuery
  attr_accessor :employee_id
  def initialize(args)
    @employee_id = args[:employee_id]
  end
end
