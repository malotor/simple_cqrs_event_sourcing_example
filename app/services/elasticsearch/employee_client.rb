class EmployeeClient
  attr_accessor :client
  include ServiceProvider::ContainerAware

  def initialize(client)
    @client = client
  end

  def save(data)
    client.index index: 'myindex', type: 'employee', id: data.aggregate_id, body: { name: data.name, title: data.title, salary: data.salary.to_i }
  end

  def update(data); end

  def search(data)
    log.debug 'DATA SEARCH: ' + data.inspect

    # response = client.search index: 'myindex', body: { query: { match: { name: 'Fred Flintstone' } } }
    response = client.search index: 'myindex', q: "name:#{data['name']}"
    log.debug 'RESPONSE: ' + response.to_s
    result = []
    response['hits']['hits'].each do |s|
      result << s['_source']
    end
    result
  end

  def reset
    client.indices.delete index: 'myindex'
  end
end
