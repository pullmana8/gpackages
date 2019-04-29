require 'virtus'

class Useflag
  include Virtus.model
  include Kkuleomi::Store::Model

  # index_name "useflags-#{Rails.env}"

  attribute :name,              String, mapping: { type: 'keyword' }
  attribute :description,       String, mapping: { type: 'text' }
  attribute :atom,              String, mapping: { type: 'keyword' }
  attribute :scope,             String, mapping: { type: 'keyword' }
  attribute :use_expand_prefix, String, mapping: { type: 'keyword' }

  def all_fields
    [:name, :description, :atom, :scope, :use_expand_prefix]
  end

  def to_param
    name
  end

  def strip_use_expand
    name.gsub(use_expand_prefix + '_', '')
  end

  class << self
    # Retrieves all flags sorted by their state
    def get_flags(name)
      result = { local: {}, global: [], use_expand: [] }

      find_all_by(:name, name).each do |flag|
        case flag.scope
        when 'local'
          result[:local][flag.atom] = flag
        when 'global'
          result[:global] << flag
        when 'use_expand'
          result[:use_expand] << flag
        end
      end

      result
    end

    def suggest(q)
      results = Useflag.search(
        size: 20,
        query: { match_phrase_prefix: { name: q } }
      )

      processed_results = {}
      results.each do |result|
        if processed_results.key? result.name
          processed_results[result.name] = {
            name: result.name,
            description: '(multiple definitions)',
            scope: 'multi'
          }
        else
          processed_results[result.name] = result
        end
      end

      processed_results.values.sort { |a, b| a[:name].length <=> b[:name].length }
    end

    # Loads the local USE flags for a given package in a name -> model hash
    #
    # @param [String] atom Package to find flags for
    # @return [Hash]
    def local_for(atom)
      map_by_name find_all_by(:atom, atom)
    end

    # Maps the global USE flags in the index by their name
    # This is expensive!
    #
    def global
      map_by_name find_all_by(:scope, 'global')
    end

    # Maps the USE_EXPAND variables in the index by their name
    #
    def use_expand
      map_by_name find_all_by(:scope, 'use_expand')
    end

    private

    def map_by_name(collection)
      map = {}

      collection.each do |item|
        map[item.name] = item
      end

      map
    end
  end
end
