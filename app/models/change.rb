require 'elasticsearch/persistence'

class Change
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL
  include Kkuleomi::Store::Model

  index_name "change-#{Rails.env}"

  mapping do
    indexes :package,     type: 'keyword'
    indexes :category,    type: 'keyword'
    indexes :change_type, type: 'keyword'
    indexes :version,     type: 'keyword'
    indexes :arches,      type: 'keyword'
    indexes :commit, { type: 'object' }
  end
end
