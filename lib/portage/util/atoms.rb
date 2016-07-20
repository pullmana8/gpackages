class Portage::Util::Atoms
  class << self
    # Parses an atom into its parts.
    # TODO: This is very resilient to malformed version strings
    #
    # @param [String] str
    # @return [Hash]
    # @raise [Portage::Ebuild::InvalidAtomError]
    def parse(str)
      result = { prefix: nil, cmp: nil, category: nil, package: nil, version: nil, postfix: nil, slot: nil, subslot: nil }

      if str.start_with? '~'
        result[:prefix] = '~'
        str = str[1..-1]
      end

      if str =~ /^(>|>=|=|<=|<)[A-Za-z0-9]/
        result[:cmp] = $1
        str = str[$1.length..-1]
      end

      if str =~ /^([A-Za-z0-9][A-Za-z0-9+_.-]+)\/([^:]*)(:.*)?$/
        result[:category] = $1
        result[:package] = $2
        package_parts = $2.split('-')
        result[:slot], result[:subslot] = $3[1..-1].split('/') if $3

        revision = ''
        if package_parts.last =~ /^r\d+$/
          revision = '-%s' % package_parts.last
          package_parts.pop
        end

        if package_parts.last =~ /^[0-9]/
          ver = package_parts.last

          if ver.last.end_with? '*'
            result[:postfix] = '*'
            ver = ver[0..-2]
          end

          result[:version] = ver + revision
          result[:package] = package_parts[0..-2].join('-')
        end

      else
        raise Portage::Ebuild::InvalidAtomError, "Cannot parse atom #{str}."
      end

      result
    end

    # Ascertains whether a version matches a given dependency atom.
    # Package names are NOT considered.
    #
    # @param [String] atom Atom to match against
    # @param [String] version Version that should match
    # @return [Boolean] true if the version is matched by the atom
    def matches?(atom, version, slot = '0')
      _atom = parse(atom)

      # 'foo-bar/baz', i.e. match all versions
      return true if _atom[:slot].nil? and _atom[:cmp].nil? and _atom[:prefix].nil?

      # Check for mismatched slots early
      if _atom[:slot]
        return false unless _atom[:slot] == slot

        # No further filtering needed?
        return true if _atom[:cmp].nil? and _atom[:version].nil? and _atom[:prefix].nil?
      end

      # Now, the slot matches, match the version
      if _atom[:postfix] and _atom[:postfix].include? '*'
        return version.match(_atom[:version].gsub(/\*$/, '.*'))
      end

      # Real version comparing starts now
      _version = Portage::Util::Versions.parse(version)
      _atom_version = Portage::Util::Versions.parse(_atom[:version])

      # '~' Operator?
      if _atom[:prefix] and _atom[:prefix].include? '~'
        _cmp = _atom_version[:num] == _version[:num] &&
            _atom_version[:alph] == _version[:alph] &&
            _atom_version[:suffixes] == _version[:suffixes]
        return _cmp
      end

      # Okay, let's compare.
      _cmp = Portage::Util::Versions.compare(_atom[:version], version)

      # version higher than atom
      if _cmp == 0
        return _atom[:cmp].include? '='
      elsif _cmp == -1
        return _atom[:cmp][0] == '>'
      elsif _cmp == 1
        return _atom[:cmp][0] == '<'
      end

      # This should technically not happen
      false
    end

  end
end
