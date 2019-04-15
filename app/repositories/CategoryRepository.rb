require 'elasticsearch/persistence'

class CategoryRepository
	include Elasticsearch::Persistence::Repository
	include Elasticsearch::Persistence::Repository::DSL

  index_name 'categories-#{Rails-env}'
  klass Category

  mapping do
    indexes :name,          type: 'keyword'
    indexes :description,   type: 'text'
    indexes :metadata_hash, type: 'text'
  end

  def all(field, order, options = {})
  	search({
  		query: { match_all: {} } },
  		{ sort: { field => { order: order } } 
  	}, options)
  end
end

client = Elasticsearch::Client.new(url: 'http://localhost:9200', log: true)
repository = Category.new
repository.klass