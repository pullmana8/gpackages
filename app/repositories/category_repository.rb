require 'singleton'

class CategoryRepository < BaseRepository
  include Singleton

  client ElasticsearchClient.default

  index_name "categories-#{Rails.env}"

  klass Category

  mapping do
    indexes :id, type: 'keyword'
    indexes :name, type: 'text'
    indexes :description, type: 'text'
    indexes :metadata_hash, type: 'keyword'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
  end

end
