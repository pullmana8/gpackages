module Kkuleomi::Store

  def self.create_index(force = false)
		repositories = [
			CategoryRepository,
			PackageRepository,
			VersionRepository,
			ChangeRepository,
			UseflagRepository,
		]

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
				index: { mapper: { dynamic: false } },
				mapping: { total_fields: { limit: 50000 } }
    }

		settings = JSON.parse('{ "mapping": { "total_fields": { "limit": 50000 } } }')

		# In ES 1.5, we could use 1 mega-index. But in ES6, each model needs its own.
		repositories.each { |repository|
						repository.instance.create_index!(force: true, settings: settings)
		}
  end
end
