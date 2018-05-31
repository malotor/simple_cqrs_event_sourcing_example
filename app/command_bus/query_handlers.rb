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

  include ServiceProvider::ContainerAware

  def handle(query)
    # client = ServiceProvider::Container[:elasticsearch]
    #response = elasticsearch.search query.params
    response = ElasticsearchProjection.new.search query.params
    log.debug 'RESPONSE:' + response.inspect
    response
  end
end
