require 'elasticsearch/persistence'
require 'elasticsearch/model'
require 'virtus'

class Category
  include Virtus::Model
  # IMPORTANT (antonette)
  # Persistence and Model has been separated
  # Repository is the new feature
  include Elasticsearch::Model
  include Elasticsearch::Persistence
  include Kkuleomi::Store::Model

  # IMPORTANT (antonette)
  # require elasticsearch model
  index_name "categories-#{Rails.env}"

  # IMPORTANT (antonette)
  # features from virtus
  attribute :name,          String, mapping: { type: 'keyword' }
  attribute :description,   String, mapping: { type: 'text' }
  attribute :metadata_hash, String, mapping: { type: 'text' }

  # Determines if the document model needs an update from the repository model
  #
  # @param [Portage::Repository::Category] category_model
  def needs_import?(category_model)
    metadata_hash != category_model.metadata_hash
  end

  # Populates values from a repository category model
  #
  # @param [Portage::Repository::Category] category_model Input category model
  def import(category_model)
    self.name = category_model.name
    self.description = category_model.description
    self.metadata_hash = category_model.metadata_hash
  end

  # Populates values from a repository category model and saves
  #
  # @param [Portage::Repository::Category] category_model Input category model
  def import!(category_model)
    import(category_model)
    save
  end

  # Returns the URL parameter for referencing this package (Rails internal stuff)
  def to_param
    name
  end
end
