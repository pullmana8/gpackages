module Kkuleomi::Store
  def self.refresh_index
    Category.gateway.refresh_index!
  end

  def self.create_index(force = false)
    client = Category.gateway.client
    index_name = Category.index_name

    settings_list = [
      Category.settings.to_hash,
      Package.settings.to_hash,
      Version.settings.to_hash,
      Change.settings.to_hash,
      Useflag.settings.to_hash
    ]

    mappings_list = [
      Category.mappings.to_hash,
      Package.mappings.to_hash,
      Version.mappings.to_hash,
      Change.mappings.to_hash,
      Useflag.mappings.to_hash
    ]

    settings = {
        analysis: {
            filter: {
                autocomplete_filter: {
                    type: 'edge_ngram',
                    min_gram: 1,
                    max_gram: 20,
                }
            },
            analyzer: {
                autocomplete: {
                    type: 'custom',
                    tokenizer: 'standard',
                    filter: %w(lowercase autocomplete_filter)
                }
            }
        }
    }
    settings_list.each { |setting| settings.merge! setting }

    mappings = {}
    mappings_list.each { |mapping| mappings.merge! mapping }

    client.indices.delete(index: index_name) rescue nil if force

    client.indices.create(index: index_name, body: { settings: settings, mappings: mappings })
  end
end
