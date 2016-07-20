class Package
  include Elasticsearch::Persistence::Model
  include Kkuleomi::Store::Model
  include Kkuleomi::Store::Models::PackageImport
  include Kkuleomi::Store::Models::PackageSearch

  index_name "packages-#{Rails.env}"

  attribute :category,        String, mapping: { index: 'not_analyzed' }
  attribute :name,            String, mapping: { index: 'not_analyzed' }
  attribute :name_sort,       String, mapping: { index: 'not_analyzed' }
  attribute :atom,            String, mapping: { index: 'not_analyzed' }
  attribute :description,     String
  attribute :longdescription, String
  attribute :homepage,        String, default: [], mapping: { index: 'not_analyzed' }
  attribute :license,         String, mapping: { index: 'not_analyzed' }
  attribute :licenses,        String, default: [], mapping: { index: 'not_analyzed' }
  attribute :herds,           String, default: [], mapping: { index: 'not_analyzed' }
  attribute :maintainers,     Array,  default: [], mapping: { type: 'object' }
  attribute :useflags,        Hash,   default: {}, mapping: { type: 'object' }
  attribute :metadata_hash,   String, mapping: { index: 'not_analyzed' }

  def category_model
    @category_model ||= Category.find_by(:name, category)
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
    @versions ||= Version.find_all_by_parent(self, sort: { sort_key: { order: 'asc' } })
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

  private

  # Splits a license string into single licenses, stripping the permitted logic constructs
  def split_license_str(str)
    return [] unless str

    str.split(/\s/).reject do |license|
      (not license[0] =~ /[[:alpha:]]/) or license.end_with? '?'
    end
  end
end
