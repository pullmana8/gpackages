require 'digest'
require 'elasticsearch/persistence'

class PortageRepository::Category
  include Elasticsearch::Persistence::Repository
  
  # attr_reader :name, :path

  # Creates a new Category model
  #
  # @param [String] path Category base directory path
  def initialize(path)
    unless File.directory? path
      raise ArgumentError, "#{path} does not look like a valid category for repository."
    end

    @path = path
    @name = path.split('/').last
  end

  # Returns the description of the category in English, or the requested language
  #
  # @param [Symbol] lang Requested description language
  # @return [String] Description, or nil if no description for this language is included in the metadata
  def description(lang = :en)
    metadata[lang.to_sym]
  end

  # Returns a list of available description languages
  #
  # @return [Array] Available language symbols
  def description_languages
    metadata.keys.sort
  end

  # Returns a list of packages in this category
  #
  # @return [Array] List of packages in this category
  def packages
    @packages ||= package_dirs.map {|p| Portage::Repository::Package.new(p) }
  end
  
  # Returns a given package, or nil
  #
  # TODO: Hash categories internally?
  def package(name)
    packages.each do |package|
      return package if package.name == name
    end

    nil
  end

  # Returns the hash of the metadata for this category
  #
  # @return [String] MD5 hash of the category metadata
  def metadata_hash
    Digest::MD5.file(File.join(@path, 'metadata.xml')).hexdigest
  end

  private
  def metadata
    @metadata ||= parse_metadata
  end

  def parse_metadata
    f = File.open(File.join(@path, 'metadata.xml'))
    xml = Nokogiri::XML(f)
    f.close

    res = {}

    xml.xpath('/catmetadata/longdescription').each do |desc_tag|
      lang = :en
      lang = desc_tag['lang'].downcase.to_sym if desc_tag.has_attribute? 'lang'

      res[lang] = desc_tag.text.strip.gsub(/\s+/, ' ')
    end

    res
  rescue Errno::ENOENT
    Rails.logger.warn "Cannot find metadata for category #{@name}."
    {}
  end

  # Filters the subdirectories of the category to find packages
  #
  # @return [Array] Package directories in this category
  def package_dirs
    Dir.glob("#{@path}/*").select do |d|
      File.directory?(d) and File.file?(File.join(d, 'metadata.xml'))
    end
  end
end
