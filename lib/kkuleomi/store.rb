module Kkuleomi::Store
#  def self.refresh_index
#    Category.gateway.refresh_index!
#  end
# refresh_index is only available under Elasticsearch Persistence under a class, not a module

#  def self.create_index(force = false)
#		types = [
#			Category,
#			Package,
#			Version,
#			Change,
#			Useflag,
#		]

    base_settings = {
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
        },
	#			index: { mapper: { dynamic: false } },
	#			mapping: { total_fields: { limit: 50000 } }
    }

		# In ES 1.5, we could use 1 mega-index. But in ES6, each model needs its own.
#		types.each { |type|
	# Gateway is deprecated
#						client = type.gateway.client
#						client.indices.delete(index: type.index_name) rescue nil if force
#						body = {
#							settings: type.settings.to_hash.merge(base_settings),
#						 	mappings: type.mappings.to_hash
#						}
#						client.indices.create(index: type.index_name, body: body)
#		}
  end
end
