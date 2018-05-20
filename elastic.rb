require 'elasticsearch'
require 'json'
client = Elasticsearch::Client.new url: 'http://elasticsearch:9200', log: true

client.transport.reload_connections!
client.cluster.health
#
# client.search q: 'test'
client.index index: 'myindex', type: 'mytype', id: 1, body: { name: 'Fred', title: 'Crane Operator', salary: 20_000 }
client.index index: 'myindex', type: 'mytype', id: 2, body: { name: 'Peter', title: 'Crane Operator', salary: 30_000 }
client.index index: 'myindex', type: 'mytype', id: 3, body: { name: 'William', title: 'Crane Operator', salary: 40_000 }
# => {"_index"=>"myindex", ... "created"=>true}

response = client.search index: 'myindex', body: { query: { match: { title: 'Crane Operator' } } }
# => {"took"=>2, ..., "hits"=>{"total":5, ...}}
# parsed_response = JSON.parse response
puts response['hits']['total']

response['hits']['hits'].each do |s|
  puts s['_source'].inspect
end

client.update index: 'myindex', type: 'mytype', id: 3, body: { doc: { title: 'Manager' } }

response = client.search index: 'myindex', body: { query: { range: { salary: { gte: 30_000, lte: 50_000 } } } }
# => {"took"=>2, ..., "hits"=>{"total":5, ...}}
# parsed_response = JSON.parse response
puts response['hits']['total']

response['hits']['hits'].each do |s|
  puts s['_source'].inspect
end
