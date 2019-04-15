module Kkuleomi::Store
  
  def self.create_index(force = false)
    types = [
        Category,
        Package,
        Version,
        Change,
        Useflag,
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
        index: { 
            mapper: { 
                dynamic: false } 
            },
            mapping: { 
                total_fields: { 
                    limit: 50000 }
                }
            }
            end
        end

