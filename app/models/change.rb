class Change
  include Elasticsearch::Persistence::Model
  include Kkuleomi::Store::Model

  index_name "changes-#{Rails.env}"

  attribute :package,     String, mapping: { type: 'text' }
  attribute :category,    String, mapping: { type: 'text' }
  attribute :change_type, String, mapping: { type: 'text' }
  attribute :version,     String, mapping: { type: 'text' }
  attribute :arches,      String, mapping: { type: 'text' }
  attribute :commit,      Hash,   default: {}, mapping: { type: 'object' }
end
