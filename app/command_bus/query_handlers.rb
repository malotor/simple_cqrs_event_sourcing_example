class AllEmployeesQueryHandler
  def handle(_query = nil)

    DbProjection.new.getAll
  end
end

class EmployeesDetailsQueryHandler
  def handle(query)
    DbProjection.new.getById(query.employee_id)
  end
end

class FindEmployeesByParamsQueryHandler

  include ServiceProvider::ContainerAware

  def handle(query)
    response = ElasticsearchProjection.new.search query.params
    log.debug 'RESPONSE:' + response.inspect
    response
  end
end
