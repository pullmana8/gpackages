require 'virtus'

class Version
  include Virtus.model
  include Kkuleomi::Store::Model
  include Kkuleomi::Store::Models::VersionImport

 # index_name "versions-#{Rails.env}"

  attribute :version,       String,  mapping: { type: 'keyword' }
  attribute :package,       String,  mapping: { type: 'keyword' }
  attribute :atom,          String,  mapping: { type: 'keyword' }
  attribute :sort_key,      Integer, mapping: { type: 'integer' }
  attribute :slot,          String,  mapping: { type: 'keyword' }
  attribute :subslot,       String,  mapping: { type: 'keyword' }
  attribute :eapi,          String,  mapping: { type: 'keyword' }
  attribute :keywords,      String,  mapping: { type: 'keyword' }
  attribute :masks,         Array,   default: [], mapping: { type: 'object' }
  attribute :use,           String,  default: [], mapping: { type: 'keyword' }
  attribute :restrict,      String,  default: [], mapping: { type: 'keyword' }
  attribute :properties,    String,  default: [], mapping: { type: 'keyword' }
  attribute :metadata_hash, String,  mapping: { type: 'keyword' }

  # Returns the keywording state on a given architecture
  #
  # @param [String] arch Architecture to query
  # @return [Symbol] :stable, :testing, :unavailable, :unknown
  def keyword(arch)
    @keyword_info_cache ||= parse_keywords keywords

    if @keyword_info_cache[:arches].key? arch
      @keyword_info_cache[:arches][arch]
    else
      if @keyword_info_cache[:exclude_all]
        :unavailable
      else
        :unknown
      end
    end
  end

  # Returns the effective keyword on a given architecture, accounting for masks
  #
  # @param [String] arch Architecture to query
  # @return [Symbol] Keyword status
  def effective_keyword(arch)
    if is_masked?(arch)
      :masked
    else
      keyword(arch)
    end
  end

  # Returns the masks that apply to the given architecture
  #
  def mask(arch)
    masks.reject do |m|
      if m['arch'] == '*'
        false
      else
        m['arch'] != arch
      end
    end
  end

  # Checks the masks whether one sounds like a package removal.
  def removal_pending?
    return false if masks.empty?

    masks.each do |m|
      if m['reason'].include?('removal') || m['reason'].include?('Removal')
        return true
      end
    end

    false
  end

  def is_masked?(arch = nil)
    !mask(arch).empty?
  end

  # Returns supported USE flags categorized by local, global, and USE_EXPAND
  # Typically called in the import phase, not live
  #
  # @return [Hash]
  def useflags
    @useflags ||= calc_useflags
  end

  # Retrieves the most widely used USE flags by all versions
  # Note that packages with many versions are over-represented
  def self.get_popular_useflags(n = 50)
    search(
      query: { match_all: {} },
      aggs: {
        group_by_flag: {
          terms: {
            field: 'use',
            size: n
          }
        }
      },
      size: 0
    ).response.aggregations['group_by_flag'].buckets
  end

  # Parses a keyword array and assigns tags for each arch
  #
  # @param [Array<String>] keywords Input keywords
  # @return [Hash] Parsed keywords
  def parse_keywords(keywords)
    res = { exclude_all: false, arches: {} }
    return res unless keywords

    keywords.each do |kw|
      if kw == '-*'
        res[:exclude_all] = true
        next
      end

      if kw.start_with? '-'
        res[:arches][kw[1..-1]] = :unavailable
        next
      end

      if kw.start_with? '~'
        res[:arches][kw[1..-1]] = :testing
        next
      end

      res[:arches][kw] = :stable
    end

    res
  end

  private

  def calc_useflags
    result = { local: {}, global: {}, use_expand: {} }

    local_flag_map = Useflag.local_for(atom.gsub("-#{version}", ''))
    local_flags = local_flag_map.keys

    use.sort.each do |flag|
      if local_flags.include? flag
        result[:local][flag] = local_flag_map[flag].to_hsh
      else
        useflag = Useflag.find_by(:name, flag)

        # This should not happen, but let's be sure
        next unless useflag

        if useflag.scope == 'global'
          result[:global][useflag.name] = useflag.to_hsh
        elsif useflag.scope == 'use_expand'
          prefix = useflag.use_expand_prefix.upcase
          result[:use_expand][prefix] ||= {}
          result[:use_expand][prefix][useflag.name.gsub(useflag.use_expand_prefix + '_', '')] = useflag.to_hsh
        end
      end
    end

    result
  end
end
