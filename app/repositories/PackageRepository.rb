require 'elasticsearch/persistence'

class Package
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name 'packages-#{Rails.env}'
  klass Package

  analyzed_and_raw = {
    type: 'keyword'
  }
  
  mapping do 
    indexes :category,        analyzed_and_raw
    indexes :name,            analyzed_and_raw
    indexes :name_sort,       analyzed_and_raw
    indexes :atom,            analyzed_and_raw
    indexes :description,     type: 'text'
    indexes :longdescription, type: 'text'
    indexes :homepage,        analyzed_and_raw
    indexes :licenses,        analyzed_and_raw
    indexes :herds,           analyzed_and_raw
    indexes :maintainers,     { type: 'object' }
    indexes :useflags,        { type: 'object' }
    indexes :metadata_hash,   analyzed_and_raw
  end
end
