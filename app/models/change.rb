require 'elasticsearch/persistence'
require 'elasticsearch/model'
require 'virtus'

class Change
  include Virtus::Model
  # IMPORTANT (antonette)
  # Persistence and Model has been separated
  # Repository is the new feature
  include Elasticsearch::Model
  include Elasticsearch::Persistence
  include Kkuleomi::Store::Model

  # IMPORTANT (antonette)
  # require elasticsearch model
  index_name "change-#{Rails.env}"

  # IMPORTANT (antonette)
  # features from virtus
  attribute :package,     String, mapping: { type: 'keyword' }
  attribute :category,    String, mapping: { type: 'keyword' }
  attribute :change_type, String, mapping: { type: 'keyword' }
  attribute :version,     String, mapping: { type: 'keyword' }
  attribute :arches,      String, mapping: { type: 'keyword' }
  attribute :commit,      Hash,   default: {}, mapping: { type: 'object' }
end
