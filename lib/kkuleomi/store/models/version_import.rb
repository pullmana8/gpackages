# Contains the import logic for versions
module Kkuleomi::Store::Models::VersionImport
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
  end

  module InstanceMethods
    # Determines if the current version document needs an update from the model
    #
    # @param [Portage::Repository::Ebuild] ebuild_model Ebuild model
    def needs_import?(ebuild_model)
      metadata_hash != ebuild_model.metadata_hash
    end

    # Imports data from an ebuild model and saves the object
    #
    # @param [Portrage::Repository::Ebuild] ebuild_model
    def import!(ebuild_model, parent_package, options)
      self.version = ebuild_model.version
      self.atom = ebuild_model.to_cpv
      self.package = parent_package.atom

      raw_slot = nil
      raw_subslot = nil
      raw_slot, raw_subslot = ebuild_model.metadata[:slot].split '/' if ebuild_model.metadata[:slot]
      self.slot = raw_slot || ''
      self.subslot = raw_subslot || ''

      old_keywords = keywords
      self.keywords = ebuild_model.metadata[:keywords] || []
      self.use = strip_useflag_defaults(ebuild_model.metadata[:iuse] || []).uniq
      self.restrict = ebuild_model.metadata[:restrict] || []
      self.properties = ebuild_model.metadata[:properties] || []
      self.masks = Portage::Util::Masks.for(ebuild_model)
      self.metadata_hash = ebuild_model.metadata_hash

      save()

      # If keywords changed, calculate changes and record as needed (but only do that if we should)
      unless options[:suppress_change_objects]
        RecordChangeJob.perform_later(
          type: 'version_bump',
          category: parent_package.category,
          package: parent_package.name,
          version: version
        ) if options[:package_state] != 'new' && options[:version_state] == 'new'

        process_keyword_diff(old_keywords, keywords, parent_package) unless old_keywords == keywords
        Rails.cache.delete("changelog/#{parent_package.atom}")
      end
    end

    # Convenience method to set the sort key and save the model
    #
    # @param [Integer] sort_key Sort key to set
    # @param [Package] parent Parent package model
    def set_sort_key!(key, parent)
      self.sort_key = key
      save(parent: parent.id)
    end

    def strip_useflag_defaults(flags)
      flags.map { |flag| flag.start_with?('+', '-') ? flag[1..-1] : flag }
    end

    def process_keyword_diff(old_kws_raw, new_kws_raw, package)
      stabled = []
      keyworded = []

      old_kws = parse_keywords old_kws_raw
      new_kws = parse_keywords new_kws_raw

      (old_kws[:arches].keys | new_kws[:arches].keys).each do |arch|
        old = old_kws[:arches][arch]
        new = new_kws[:arches][arch]

        if old && new
          next if old == new

          if old == :unavailable && new == :testing
            keyworded << arch
          elsif old == :unavailable && new == :stable
            stabled << arch
          elsif old == :testing && new == :stable
            stabled << arch
          end
        elsif new && !old
          if new == :testing
            keyworded << arch
          elsif new == :stable
            stabled << arch
          end
        end
      end

      unless stabled.empty?
        RecordChangeJob.perform_later(
          type: 'stable',
          category: package.category,
          package: package.name,
          version: version,
          arches: stabled
        )
      end

      unless keyworded.empty?
        RecordChangeJob.perform_later(
          type: 'keyword',
          category: package.category,
          package: package.name,
          version: version,
          arches: keyworded
        )
      end
    end
  end
end
