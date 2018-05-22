class EmployeeClient

  attr_accessor :client

  def initialize(client)
    @client = client
  end

  def save(data)
    client.index index: 'myindex', type: 'employee', id: data.aggregate_id, body: { name: data.name, title: data.title, salary: data.salary.to_i }
  end

  def update(data)
  end

  def search(data)
    response = client.search index: 'myindex', body: { query: { match: { name: data[:name] } } }
  end

  def reset()
    client.delete_by_query index: 'myindex', body: { query: { match_all: {} } }

  end

end
