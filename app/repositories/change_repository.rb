require 'singleton'

class ChangeRepository < BaseRepository
  include Singleton

  client ElasticsearchClient.default

  index_name "change-#{Rails.env}"

  klass Change

  mapping do
    indexes :package, type: 'keyword'
    indexes :category, type: 'keyword'
    indexes :change_type, type: 'keyword'
    indexes :version, type: 'keyword'
    indexes :arches, type: 'keyword'
    indexes :commit, type: 'object'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
  end

end
