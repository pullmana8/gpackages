class ElasticsearchClient

  def self.default
    @default ||= Elasticsearch::Client.new host: ENV['ELASTICSEARCH_URL'] || 'localhost:9200'
  end

  private

  def initialize(*)
    raise "Should not be initialiazed"
  end

end