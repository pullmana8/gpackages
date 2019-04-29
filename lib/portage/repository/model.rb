require 'elasticsearch/persistence'

# Describes a portage repository identified by its base path
class PortageRepository::Model
  include Elasticsearch::Persistence::Repository
  
  # attr_reader :repo_name, :path

  def initialize(path)
    @path = path
    @repo_name = File.read(File.join(path, 'profiles', 'repo_name')).strip
  end

  # Returns the categories contained within this repository
  #
  # @return [Array[Portage::Repository::Category]] List of categories
  def categories
    @categories ||= category_dirs.map {|c| Portage::Repository::Category.new(File.join(@path, c)) }
  end

  # Returns a given category, or nil
  #
  # TODO: Hash categories internally?
  def category(name)
    categories.each do |category|
      return category if category.name == name
    end

    nil
  end

  # Returns the global USE flags described in this repositorie's use.desc file
  #
  # @return [Hash{String => String}] Hash of USE flags mapped to their description.
  def global_useflags
    @useflags ||= parse_useflags(File.join(@path, 'profiles', 'use.desc'))
  end

  # Returns the USE_EXPAND flags described in the repository
  #
  # @return [Hash{String => Hash{String => String}}] Hash of USE_EXPAND variables mapped to possible values mapped to their description.
  def use_expand_flags
    @use_expand_flags ||= parse_use_expand_flags
  end

  private
  # Filters the subdirectories of the repository to find categories
  #
  # @return [Array] Category directories in this repository
  def category_dirs
    File.read(File.join(@path, 'profiles', 'categories')).lines.map {|line| line.strip}
  end

  def parse_use_expand_flags
    flags = {}

    Dir.glob(File.join(@path, 'profiles', 'desc', '*.desc')) do |desc_file|
      flags[desc_file.split('/').last.gsub('.desc', '')] = parse_useflags(desc_file)
    end

    flags
  end

  def parse_useflags(file)
    flags = {}

    File.readlines(file).each do |line|
      next if line =~ /^(|#.*)$/

      flag, desc = line.strip.split(' - ', 2)
      flags[flag] = desc
    end

    flags
  end
end
