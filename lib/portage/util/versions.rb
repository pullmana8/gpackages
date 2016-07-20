class Portage::Util::Versions
  class << self
    # Compares an two ebuild version strings with each other as per PMS.
    #
    # @param [String] a_ver
    # @param [String] b_ver
    # @return [Integer] -1 if b > a; 0 if a == b; 1 if b < a
    def compare(a_ver, b_ver)
      a = parse a_ver
      b = parse b_ver

      comparison_1 = compare_numbers(a, b)
      return comparison_1 unless comparison_1 == 0

      comparison_2 = compare_letters(a, b)
      return comparison_2 unless comparison_2 == 0

      comparison_3 = compare_suffixes(a, b)
      return comparison_3 unless comparison_3 == 0

      comparison_4 = compare_revisions(a, b)
      return comparison_4 unless comparison_4 == 0

      # Give up: they're equal
      0
    end

    # Parses a version string into its parts.
    # TODO: This is very resilient to malformed version strings
    #
    # @param [String] str
    # @return [Hash]
    # @raise [Portage::Ebuild::InvalidVersionError]
    def parse(str)
      def number_conv(num)
        if num.start_with? '0'
          num
        else
          num.to_i
        end
      end

      raw_parts = str.split(/[\._-]/)
      result = { num: [], num_count: 0, alph: nil, suffixes: [], suffix_count: 0, revision: 0 }

      raw_parts.each do |raw_part|
        if raw_part.is_i?
          result[:num] << number_conv(raw_part)
          result[:num_count] += 1
        elsif raw_part =~ /^(\d+)([a-z])$/
          result[:num] << number_conv($1)
          result[:num_count] += 1
          result[:alph] = $2
        elsif raw_part =~ /^(alpha|beta|pre|rc|p)(\d+)?$/
          result[:suffixes] << [$1, $2 == nil ? nil : $2.to_i]
          result[:suffix_count] += 1
        elsif raw_part =~ /^r(\d+)$/
          result[:revision] = $1.to_i
        else
          raise Portage::Ebuild::InvalidVersionError, "Unknown version component: #{raw_part}"
        end
      end

      result
    end

    private
    # Algorithm 2
    def compare_numbers(a, b)
      return  1 if a[:num].first.to_i > b[:num].first.to_i
      return -1 if a[:num].first.to_i < b[:num].first.to_i

      (0...[a[:num_count], b[:num_count]].min).each do |i|
        # Algorithm 3
        if a[:num][i].is_a? String or b[:num][i].is_a? String
          cmp = a[:num][i].to_s <=> b[:num][i].to_s
          return cmp unless cmp == 0
        else
          cmp = a[:num][i].to_i <=> b[:num][i].to_i
          return cmp unless cmp == 0
        end
      end

      return  1 if a[:num_count] > b[:num_count]
      return -1 if a[:num_count] < b[:num_count]

      0
    end

    def compare_letters(a, b)
      a_letter = a[:alph] || ''
      b_letter = b[:alph] || ''

      a_letter <=> b_letter
    end

    # Algorithm 5
    def compare_suffixes(a, b)
      suffix_order = %w[ alpha beta pre rc p ]

      (0...[a[:suffix_count], b[:suffix_count]].min).each do |i|
        # Algorithm 6
        if a[:suffixes][i].first == b[:suffixes][i].first
          suffix_cmp = (a[:suffixes][i].last || 0) <=> (b[:suffixes][i].last || 0)
          return suffix_cmp unless suffix_cmp == 0
        else
          a_order = suffix_order.find_index a[:suffixes][i].first
          b_order = suffix_order.find_index b[:suffixes][i].first

          order_cmp = a_order <=> b_order
          return order_cmp unless order_cmp == 0
        end
      end

      if a[:suffix_count] > b[:suffix_count]
        return a[:suffixes].last[0] == 'p' ? 1 : -1
      elsif a[:suffix_count] < b[:suffix_count]
        return b[:suffixes].last[0] == 'p' ? -1 : 1
      end

      0
    end

    # Algorithm 7
    def compare_revisions(a, b)
      a[:revision] <=> b[:revision]
    end
  end
end