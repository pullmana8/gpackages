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
  "mappings": {
    "dynamic": "false",
    "settings": {
      "number_of_shards": 1,
      "analysis": {
        "filter": {
          "autocomplete_filter": {
            "type": "edge_ngram",
            "min_gram": 2,
            "max_gram": 10
          }
        },
        "analyzer": {
          "autocomplete": {
            "type": "custom",
            "tokenizer": "standard",
            "filter": [
              "lowercase",
              "autocomplete_filter"
            ]
          }
        },
        "index": {
          "mapping": {
            "total_fields": {
              "limit": 50000
            }
          }
        },
        "properties": {
          "package": {
            "properties": {
              "category": {
                "type": "string",
                "analyzer": "autocomplete",
                "search_analyzer": "standard",
                "fields": {
                  "raw": {
                    "type": "string"
                  },
                  "english": {
                    "type": "text",
                    "analyzer": "english"
                  }
                }
              },
              "name": {
                "type": "string",
                "fields": {
                  "raw": {
                    "type": "string"
                  }
                }
              },
              "homepace": {
                "type": "string",
                "fields": {
                  "raw": {
                    "type": "string"
                  }
                }
              },
              "licenses": {
                "type": "string",
                "fields": {
                  "raw": {
                    "type": "string"
                  }
                }
              },
              "herds": {
                "type": "string",
                "fields": {
                  "raw": {
                    "type": "string"
                  }
                }
              },
              "metadata_hash": {
                "type": "string",
                "fields": {
                  "raw": {
                    "type": "string"
                  }
                }
              }
            }
          },
          "category": {
            "name": {
              "type": "text"
            },
            "description": {
              "type": "text"
            },
            "metadata_hash": {
              "type": "text"
            }
          },
          "change": {
            "package": {
              "type": "keyword"
            },
            "category": {
              "type": "keyword"
            },
            "change_type": {
              "type": "keyword"
            },
            "version": {
              "type": "keyword"
            },
            "arches": {
              "type": "keyword"
            },
            "commit": {
              "type": "objecT",
              "fields": {
                "hash": {
                  "type": "murmur3"
                }
              }
            }
          }
        }
      }
    }
  }
}
  end
end
