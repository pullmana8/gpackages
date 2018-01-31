require 'digest'
class Portage::Repository::Package
  attr_reader :category, :name, :path

  # Creates a new Package model
  #
  # @param [String] path Path of the package base directory
  def initialize(path)
    unless File.directory? path
      fail ArgumentError, "'#{path}' is not a directory, and thus can't be a package directory."
    end

    @path = path
    path_parts = path.split '/'
    @name = path_parts.last
    @category = path_parts[-2]
  end

  # Renders the package name as 'cp' string (category + package)
  #
  # @return [String] CP string
  def to_cp
    "#{@category}/#{@name}"
  end

  # Returns the available ebuilds (versions) for this package *unsorted*
  #
  # @return [Array<Portage::Repository::Ebuild>] Available ebuilds
  def ebuilds
    @ebuilds ||= ebuild_files.map { |e| Portage::Repository::Ebuild.new(e) }
  end

  # Returns the available ebuilds sorted by their version string.
  #
  # @return [Array<Portage::Repository::Ebuild] Available ebuilds in a sorted array
  def ebuilds_sorted
    @ebuilds_sorted ||= ebuilds.sort { |a, b| Portage::Util::Versions.compare(a.version, b.version) }
  end

  def metadata
    @metadata ||= Portage::Util::Metadata.new(File.join(@path, 'metadata.xml'))
  end

  def metadata_hash
    Digest::MD5.hexdigest("#{metadata.hash}" + ebuilds.map(&:metadata_hash).join(' '))
  end

  def inspect
    "#<Package '#{@name}' @category='#{@category}' @path='#{@path}'>"
  end

  private

  # Filters the files of the package to find ebuilds
  #
  # @return [Array<String>] Ebuild files in this category
  def ebuild_files
    Dir.glob(File.join(@path, '*.ebuild'))
  end
end
