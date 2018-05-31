class AllEmployeesQueryHandler
  def handle(query)
    DbProjection.new.getAll(query.page, query.offset)
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
