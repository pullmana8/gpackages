require 'elasticsearch'
require 'elasticsearch/transport'

client = Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL'], log: true)

# Debug environment to see logs via rails s
if Rails.env.development? or ENV['RAILS_DEBUG']
	client = Elasticsearch::Client.new log:true
	# require 'elasticsearch/transport'
	response = client.perform_request 'GET', '_cluster/health'

	# require 'elasticsearch'
	client.transport.reload_connections!
	client.cluster.health
	client.search q: 'test'

	client.index index: 'test_index', type: 'index', id: 1, body: { title: 'Test' }

	client.search index: 'test_index', body: { query: { match: { title: 'test' } } }
end