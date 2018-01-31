require 'digest'
class Portage::Repository::Ebuild
  attr_reader :package, :name, :path, :version, :category, :repo_root

  # Creates a new ebuild model instance
  #
  # @param [String] path File path to the ebuild
  def initialize(path)
    unless File.file? path
      fail ArgumentError, "#{name} does not look like a valid ebuild."
    end

    @path = path
    path_parts = path.split '/'

    @repo_root = File.join(File.dirname(path), '..', '..')
    @category = path_parts[-3]
    @package = path_parts[-2]
    @name = path_parts.last

    if @name =~ /^#{Regexp.escape @package}-(.*)\.ebuild$/
      @version = $1
    else
      fail ArgumentError, "#{name} does not look like a valid ebuild name for package #{package}."
    end
  end

  def to_s
    "#{@category}/#{@name}"
  end

  def to_cp
    "#{@category}/#{@package}"
  end

  def to_cpv
    "#{@category}/#{to_pv}"
  end

  def to_pv
    @name.gsub(/\.ebuild$/, '')
  end

  def metadata
    @metadata ||= Portage::Util::MetadataCache.new self
  end

  def metadata_hash
    Digest::MD5.hexdigest("#{metadata.hash}#{Portage::Util::Masks.for(self).hash}")
  end

  def inspect
    "#<Ebuild '#{@name}' @package='#{@package}' @path='#{@path}'>"
  end
end
