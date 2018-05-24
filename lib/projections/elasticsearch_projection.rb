class ElasticsearchProjection

  include Projection

  def initialize()
      @log = ServiceProvider::Container[:log]
      @client = ServiceProvider::Container[:elasticsearch]
  end

  project NewEmployeeIsHiredEvent do |event|
    @log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    @client.save event
  end

  project SalaryHasChangedEvent do |event|
    @log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    # TODO
  end
end
