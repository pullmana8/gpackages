require 'virtus'

class Change
  include Virtus.model
  include Kkuleomi::Store::Model

  # index_name "change-#{Rails.env}"

  attribute :package,     String, mapping: { type: 'keyword' }
  attribute :category,    String, mapping: { type: 'keyword' }
  attribute :change_type, String, mapping: { type: 'keyword' }
  attribute :version,     String, mapping: { type: 'keyword' }
  attribute :arches,      String, mapping: { type: 'keyword' }
  attribute :commit,      Hash,   default: {}, mapping: { type: 'object' }
end
