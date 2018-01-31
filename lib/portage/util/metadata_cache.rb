require 'digest'
class Portage::Util::MetadataCache
  # Parses the metadata cache entries for the given ebuild
  #
  # @param [Portage::Repository::Ebuild] ebuild Ebuild to parse metadata for
  def initialize(ebuild)
    @file = File.join(ebuild.repo_root, 'metadata', 'md5-cache', ebuild.category, ebuild.to_pv)
    cache_f = File.open(@file)
    @metadata = parse(cache_f)
    cache_f.close
  end

  def hash
    Digest::MD5.file(@file).hexdigest
  end

  # Returns information from the portage metadata cache
  # Values: :depend, :rdepend, :slot, :src_uri, :restrict, :homepage,
  # :license, :description, :keywords, :iuse, :required_use,
  # :pdepend, :provide, :eapi, :properties, :defined_phases
  # as per portage/pym/portage/cache/metadata.py (database.auxdbkey_order)
  #
  # @param [String] key Requested information key as above
  # @return [String, Array] Requested information
  def [](key)
    @metadata[key]
  end

  # Based on a function I wrote for GLSAMaker.
  #
  # @param [File] f File to read metadata cache from
  # @return [Hash{Symbol => String, Array}] A hash with all available metadata (see above for keys)
  def parse(f)
    # noinspection RubyStringKeysInHashInspection
    items = {
      'DEFINED_PHASES' => :defined_phases,
      'DEPEND'         => :depend,
      'DESCRIPTION'    => :description,
      'EAPI'           => :eapi,
      'HOMEPAGE'       => :homepage,
      'IUSE'           => :iuse,
      'KEYWORDS'       => :keywords,
      'LICENSE'        => :license,
      'PDEPEND'        => :pdepend,
      'PROPERTIES'     => :properties,
      'RDEPEND'        => :rdepend,
      'RESTRICT'       => :restrict,
      'REQUIRED_USE'   => :required_use,
      'SLOT'           => :slot,
      'SRC_URI'        => :src_uri
    }

    valid_keys = items.keys

    # List of metadata items to split at space
    split_keys = %w[ SRC_URI IUSE KEYWORDS PROPERTIES RESTRICT DEFINED_PHASES ]

    r = Regexp.compile('^(\\w+)=([^\n]*)')
    result = {}

    while f.gets
      if (match = r.match($_)) != nil and valid_keys.include? match[1]
        if split_keys.include? match[1]
          result[items[match[1]]] = match[2].split(' ')
        else
          result[items[match[1]]] = match[2]
        end
      end
    end

    result
  end
end
