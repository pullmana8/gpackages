class Change
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = [:_id,
                :created_at,
                :updated_at,
                :package,
                :category,
                :change_type,
                :version,
                :arches,
                :commit]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates :package, presence: true

  def initialize(attr={})
    attr.each do |k,v|
      if ATTRIBUTES.include?(k.to_sym)
        send("#{k}=", v)
      end
    end
  end

  def attributes
    @created_at ||= DateTime.now
    @updated_at = DateTime.now
    ATTRIBUTES.inject({}) do |hash, attr|
      if value = send(attr)
        hash[attr] = value
      end
      hash
    end
  end
  alias :to_hash :attributes

  # Converts the model to an OpenStruct instance
  #
  # @param [Array<Symbol>] fields Fields to export into the OpenStruct, or all fields if nil
  # @return [OpenStruct] OpenStruct containing the selected fields
  def to_os(*fields)
    fields = all_fields if fields.empty?
    OpenStruct.new(Hash[fields.map { |field| [field, send(field)] }])
  end

end
