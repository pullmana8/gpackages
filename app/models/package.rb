class Package
  include ActiveModel::Model
  include ActiveModel::Validations
  include Kkuleomi::Store::Models::PackageImport

  ATTRIBUTES = [:id,
                :created_at,
                :updated_at,
                :category,
                :name,
                :name_sort,
                :atom,
                :description,
                :longdescription,
                :homepage,
                :license,
                :licenses,
                :herds,
                :maintainers,
                :useflags,
                :metadata_hash]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates :name, presence: true

  def initialize(attr={})
    attr.each do |k,v|
      if ATTRIBUTES.include?(k.to_sym)
        send("#{k}=", v)
      end
    end
  end

  def attributes
    @id = @atom
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

  def category_model
    @category_model ||= CategoryRepository.find_by(:name, category)
  end

  def to_param
    atom
  end

  # Are all of the versions of this package pending for removal?
  #
  # @return [Boolean] true, if all of the versions' masks look like a removal mask
  def removal_pending?
    versions.map(&:removal_pending?).uniq == [true]
  end

  def has_useflags?
    useflags && !(useflags['local'].empty? && useflags['global'].empty? && useflags['use_expand'])
  end

  def versions
    @versions ||= VersionRepository.find_all_by(:package, atom, sort: { sort_key: { order: 'asc' } })
  end

  def latest_version
    versions.first
  end

  def version(version_str)
    versions.each { |version| return version if version.version == version_str }

    nil
  end

  # Does this package need a maintainer?
  #
  # @return [Boolean] true, if it is assigned to maintainer-needed or has no maintainers
  def needs_maintainer?
    (maintainers.size == 1 && maintainers.first['email'] == 'maintainer-needed@gentoo.org') ||
      maintainers.empty? && herds.empty?
  end

  # Converts the model to an OpenStruct instance
  #
  # @param [Array<Symbol>] fields Fields to export into the OpenStruct, or all fields if nil
  # @return [OpenStruct] OpenStruct containing the selected fields
  def to_os(*fields)
    fields = all_fields if fields.empty?
    OpenStruct.new(Hash[fields.map { |field| [field, send(field)] }])
  end

  private

  # Splits a license string into single licenses, stripping the permitted logic constructs
  def split_license_str(str)
    return [] unless str

    str.split(/\s/).reject do |license|
      (not license[0] =~ /[[:alpha:]]/) or license.end_with? '?'
    end
  end
end
