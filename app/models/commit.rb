class Commit
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = [:id,
                :author,
                :email,
                :date,
                :message,
                :files,
                :packages,
                :created_at,
                :updated_at]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

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

end
