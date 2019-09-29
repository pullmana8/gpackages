require 'singleton'

class VersionRepository < BaseRepository
  include Singleton

  class << self
    extend Forwardable
    def_delegators :instance, :get_popular_useflags
  end

  index_name "versions-#{Rails.env}"

  klass Version

  mapping do
    indexes :version, type: 'keyword'
    indexes :package, type: 'keyword'
    indexes :atom, type: 'keyword'
    indexes :sort_key, type: 'integer'
    indexes :slot, type: 'keyword'
    indexes :subslot, type: 'keyword'
    indexes :eapi, type: 'keyword'
    indexes :keywords, type: 'keyword'
    indexes :masks do
      indexes :arches, type: 'keyword'
      indexes :atoms, type: 'keyword'
      indexes :author, type: 'keyword'
      indexes :date, type: 'keyword'
      indexes :reason, type: 'text'
    end
    indexes :use, type: 'keyword'
    indexes :restrict, type: 'keyword'
    indexes :properties, type: 'keyword'
    indexes :metadata_hash, type: 'keyword'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
  end

  # Retrieves the most widely used USE flags by all versions
  # Note that packages with many versions are over-represented
  def get_popular_useflags(n = 50)
    search(
      query: { match_all: {} },
      aggs: {
        group_by_flag: {
          terms: {
            field: 'use',
            size: n
          }
        }
      },
      size: 0
    ).response.aggregations['group_by_flag'].buckets
  end

end
