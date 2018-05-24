class ElasticsearchProjection

  include Projection

  def initialize()
      @log = ServiceProvider::Container[:log]
      @client = ServiceProvider::Container[:elasticsearch]
  end
  #
  # def project(event)
  #   self.send("project_#{event.class.name}",event)
  # end

  project NewEmployeeIsHiredEvent do |event|
    @log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    @client.save event
  end

  project SalaryHasChangedEvent do |event|
    @log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    # TODO
    #db = ActiveRecord::Base.connection
    #db.execute("UPDATE employee_views SET salary = ?  WHERE uuid = '?'", [event.new_salary.to_i, event.aggregate_id])
  end
end
