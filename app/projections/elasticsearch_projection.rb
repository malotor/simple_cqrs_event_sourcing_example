class ElasticsearchProjection

  #attr_accessor :client

  include Projection
  include ServiceProvider::ContainerAware

  def search(data)
    log.debug 'DATA SEARCH: ' + data.inspect

    # response = client.search index: 'myindex', body: { query: { match: { name: 'Fred Flintstone' } } }
    response = elasticsearch.search index: 'myindex', q: "name:#{data['name']}"
    log.debug 'RESPONSE: ' + response.to_s
    result = []
    response['hits']['hits'].each do |s|
      result << s['_source']
    end
    result
  end

  project NewEmployeeIsHiredEvent do |event|
    log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    save event
  end

  project SalaryHasChangedEvent do |event|
    log.debug "[Elasticsearch] Projecting Event: #{event.inspect}"
    # TODO
  end

  private

    def save(data)
      elasticsearch.index index: 'myindex', type: 'employee', id: data.aggregate_id, body: { name: data.name, title: data.title, salary: data.salary.to_i }
    end

    def update(data); end

end
