class Category
  include Elasticsearch::Persistence::Model
  include Kkuleomi::Store::Model

  index_name "packages-#{Rails.env}"

  attribute :name,          String, mapping: { index: 'not_analyzed' }
  attribute :description,   String
  attribute :metadata_hash, String, mapping: { index: 'not_analyzed' }

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
