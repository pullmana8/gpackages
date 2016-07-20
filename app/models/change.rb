class Change
  include Elasticsearch::Persistence::Model
  include Kkuleomi::Store::Model

  index_name "packages-#{Rails.env}"

  attribute :package,     String, mapping: { index: 'not_analyzed' }
  attribute :category,    String, mapping: { index: 'not_analyzed' }
  attribute :change_type, String, mapping: { index: 'not_analyzed' }
  attribute :version,     String, mapping: { index: 'not_analyzed' }
  attribute :arches,      String, mapping: { index: 'not_analyzed' }
  attribute :commit,      Hash,   default: {}, mapping: { type: 'object' }
end
