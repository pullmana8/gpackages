module Kkuleomi::Store::Model
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
    # Finds instances by exact IDs using the 'term' filter
    def find_all_by(field, value, opts = {})
      search({
        size: 10_000,
        query: { bool: { filter: { term: { field => value } } } }
      }.merge(opts))
    end

    # Filter all instances by the given parameters
    def filter_all(filters, opts = {})
      filter_args = []
      filters.each_pair { |field, value| filter_args << { term: { field => value } } }

      search({
        query: {
          bool: { filter: { bool: { must: filter_args } } }
        },
        size: 10_000
      }.merge(opts))
    end

    def find_by(field, value, opts = {})
      find_all_by(field, value, opts).first
    end

		def find_all_by_package(package, opts = {})
			search(opts.merge(
				size: 10_000,
				query: {
				  bool: {
						filter: {
						  term: { package: package }
						}
					},
				}
			))
		end

    def find_all_by_parent(parent, opts = {})
      search(opts.merge(
        size: 10_000,
        query: {
          bool: {
            filter: {
              has_parent: {
                parent_type: parent.class.document_type,
                query: { term: { _id: parent.id } }
              }
            },
            must: { match_all: {} }
          }
        }
      ))
    end

    # Returns all (by default 10k) records of this class sorted by a field.
    def all_sorted_by(field, order, options = {})
      all({
            query: { match_all: {} },
            sort: { field => { order: order } }
          }, options)
    end
  end

  module InstanceMethods
    # Converts the model to an OpenStruct instance
    #
    # @param [Array<Symbol>] fields Fields to export into the OpenStruct, or all fields if nil
    # @return [OpenStruct] OpenStruct containing the selected fields
    def to_os(*fields)
      fields = all_fields if fields.empty?
      OpenStruct.new(Hash[fields.map { |field| [field, send(field)] }])
    end

    # Converts the model to a Hash
    #
    # @param [Array<Symbol>] fields Fields to export into the Hash, or all fields if nil
    # @return [Hash] Hash containing the selected fields
    def to_hsh(*fields)
      fields = all_fields if fields.empty?
      Hash[fields.map { |field| [field, send(field)] }]
    end
  end
end
