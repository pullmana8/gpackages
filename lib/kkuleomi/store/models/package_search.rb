# Contains the search logic for packages
module Kkuleomi::Store::Models::PackageSearch
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    def suggest(q)
      Package.search(
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

      Package.find_all_by(:atom, atom) + Package.find_all_by(:name, atom)
    end

    # Searches the versions index for versions using a certain USE flag.
    # Results are aggregated by package atoms.
    def find_atoms_by_useflag(useflag)
      Version.search(
        size: 10000, # default limit is 10.
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
              order: { '_key' => 'asc' }
            }
          }
        },
        size: 0
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
          filter: { term: { category: 'virtual' } },
          weight: 0.6
        }
      ]
    end
  end

  module InstanceMethods
  end
end
