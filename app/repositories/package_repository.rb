require 'forwardable'
require 'singleton'

class PackageRepository < BaseRepository
  include Singleton

  class << self
    extend Forwardable
    def_delegators :instance, :suggest, :resolve, :find_atoms_by_useflag, :default_search_size, :default_search,
                   :build_query, :match_wildcard, :match_phrase, :match_description, :match_category, :scoring_functions
  end

  index_name "packages-#{Rails.env}"

  klass Package

  mapping do
    indexes :category, type: 'keyword'
    indexes :name, type: 'keyword'
    indexes :name_sort, type: 'keyword'
    indexes :atom, type: 'keyword'
    indexes :description, type: 'text'
    indexes :longdescription, type: 'text'
    indexes :homepage, type: 'keyword'
    indexes :license, type: 'keyword'
    indexes :licenses, type: 'keyword'
    indexes :herds, type: 'keyword'
    indexes :maintainers, type: 'object'
    indexes :useflags, type: 'object'
    indexes :metadata_hash, type: 'keyword'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
  end

  def suggest(q)
    PackageRepository.search(
      size: 20,
      query: {
        wildcard: {
          name_sort: {
            wildcard: q.downcase + '*'
          }
        }
      }
    )
  end

  # Tries to resolve a query atom to one or more packages
  def resolve(atom)
    [] if atom.nil? || atom.empty?

    PackageRepository.find_all_by(:atom, atom) + PackageRepository.find_all_by(:name, atom)
  end

  # Searches the versions index for versions using a certain USE flag.
  # Results are aggregated by package atoms.
  def find_atoms_by_useflag(useflag)
    VersionRepository.search(
      size: 0, # collect all packages.
      query: {
        bool: {
          must: { match_all: {} },
          filter: { term: { use: useflag } }
        }
      },
      aggs: {
        group_by_package: {
          terms: {
            field: 'package',
            order: { '_key' => 'asc' },
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html
            # ES actually dislikes large sizes like this (it defines 10k buckets basically) and it will be *very* expensive but lets try it and see.
            # Other limits in this app are also 10k mostly to 'make things fit kinda'.
            size: 10000,
          }
        }
      },
    ).response.aggregations['group_by_package'].buckets
  end

  def default_search_size
    25
  end

  def default_search(q, offset)
    return [] if q.nil? || q.empty?

    part1, part2 = q.split('/', 2)

    if part2.nil?
      search(build_query(part1, nil, default_search_size, offset))
    else
      search(build_query(part2, part1, default_search_size, offset))
    end
  end

  def build_query(q, category, size, offset)
    {
      size: size,
      from: offset,
      query: {
        function_score: {
          query: { bool: bool_query_parts(q, category) },
          functions: scoring_functions
        }
      }
    }
  end

  def bool_query_parts(q, category = nil)
    q_dwncsd = q.downcase

    query = {
      must: [
        match_wildcard(q_dwncsd)
      ],
      should: [
        match_phrase(q_dwncsd),
        match_description(q)
        ]
    }

    query[:must] << [match_category(category)] if category

    query
  end

  def match_wildcard(q)
    q = ('*' + q + '*') unless q.include? '*'
    q.tr!(' ', '*')

    {
      wildcard: {
        name_sort: {
          wildcard: q,
          boost: 4
        }
      }
    }
  end

  def match_phrase(q)
    {
      match_phrase: {
        name: {
          query: q,
          boost: 5
        }
      }
    }
  end

  def match_description(q)
    {
      match: {
        description: {
          query: q,
          boost: 0.1
        }
      }
    }
  end

  def match_category(cat)
    {
      match: {
        category: {
          query: cat,
          boost: 2
        }
      }
    }
  end

  def scoring_functions
    [
      {
        filter: {
          term: {
            category: 'virtual'
          }
        },
        weight: 0.6
      }
    ]
  end

end
