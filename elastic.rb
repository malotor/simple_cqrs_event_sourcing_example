require 'elasticsearch'

client = Elasticsearch::Client.new url: 'http://elasticsearch:9200' , log: true

client.transport.reload_connections!
#
client.cluster.health
#
# client.search q: 'test'

client.index  index: 'myindex', type: 'mytype', id: 1, body: { title: 'Test' }
# => {"_index"=>"myindex", ... "created"=>true}

puts client.search index: 'myindex', body: { query: { match: { title: 'test' } } }
# => {"took"=>2, ..., "hits"=>{"total":5, ...}}
