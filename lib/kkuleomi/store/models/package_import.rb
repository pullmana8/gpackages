# Contains the import logic for packages
module Kkuleomi::Store::Models::PackageImport
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods
  end

  module InstanceMethods
    # Determines if the current package document needs an update from the model
    #
    # @param [Portage::Repository::Package] package_model Package model
    def needs_import?(package_model)
      metadata_hash != package_model.metadata_hash
    end

    # Imports data from this model. Saving is not optional here as we might need the package's ID as parent.
    #
    # @param [Portage::Repository::Package] package_model Package model
    # @param [Hash] options Import options
    def import!(package_model, options)
      # Fetch ebuilds, newest-first
      ebuilds = package_model.ebuilds_sorted.reverse
      latest_ebuild = ebuilds.first

      fail "No ebuilds found for #{package_model.name}. Skipping import." unless latest_ebuild

      set_basic_metadata(package_model, latest_ebuild)

      # Be sure to have an ID now
      save

      import_useflags!(package_model)
      Kkuleomi::Store.refresh_index
      import_versions!(package_model, ebuilds, options)

      # Do this last, so that any exceptions before this point skip this step
      self.metadata_hash = package_model.metadata_hash
      save

      if options[:package_state] == 'new' && !options[:suppress_change_objects]
        RecordChangeJob.perform_later(
          type: 'new_package',
          category: category,
          package: name
        )
      end

      Rails.cache.delete("changelog/#{package_model.to_cp}")
    end

    def set_basic_metadata(package_model, latest_ebuild)
      self.name = package_model.name
      self.name_sort = package_model.name.downcase
      self.category = package_model.category
      self.atom = package_model.to_cp

      self.description = latest_ebuild.metadata[:description]

      if (homepage = latest_ebuild.metadata[:homepage])
        self.homepage = homepage.split ' '
      end

      self.license = latest_ebuild.metadata[:license]
      self.licenses = split_license_str latest_ebuild.metadata[:license]

      self.herds = package_model.metadata[:herds]
      self.maintainers = package_model.metadata[:maintainer]

      self.longdescription = package_model.metadata[:longdescription][:en]
    end

    def import_useflags!(package_model)
      index_flags = Useflag.local_for(package_model.to_cp)
      model_flags = package_model.metadata[:use]

      new_flags = model_flags.keys - index_flags.keys
      del_flags = index_flags.keys - model_flags.keys
      eql_flags = model_flags.keys & index_flags.keys

      new_flags.each do |flag|
        flag_doc = Useflag.new
        # TODO: import! method?
        flag_doc.name = flag
        flag_doc.description = model_flags[flag]
        flag_doc.atom = package_model.to_cp
        flag_doc.scope = 'local'
        flag_doc.save
      end

      eql_flags.each do |flag|
        unless index_flags[flag].description == model_flags[flag]
          index_flags[flag].description = model_flags[flag]
          index_flags[flag].save
        end
      end

      del_flags.each do |flag|
        index_flags[flag].delete
      end
    end

    def import_versions!(package_model, ebuilds, options)
      index_v = Hash[Version.find_all_by(:package, package_model.to_cp).map { |v| [v.version, v] }]
      model_v = Hash[ebuilds.map { |v| [v.version, v] }]

      index_keys = index_v.keys
      model_keys = model_v.keys

      new_v = model_keys - index_keys
      del_v = index_keys - model_keys
      eql_v = model_keys & index_keys

      Rails.logger.debug { "#{package_model.to_cp} new: " + new_v.inspect }
      Rails.logger.debug { "#{package_model.to_cp} del: " + del_v.inspect }
      Rails.logger.debug { "#{package_model.to_cp} eql: " + eql_v.inspect }

      ebuild_order = Hash[ebuilds.each_with_index.map { |e, i| [e.version, i] }]

      new_v.each do |v|
        version_doc = Version.new
        version_doc.import!(model_v[v], self, options.merge(version_state: 'new'))

        sort_key = ebuild_order[v]
        version_doc.set_sort_key!(sort_key, self)

        if sort_key == 0
          self.useflags = version_doc.useflags
          save
        end
      end

      eql_v.each do |v|
        version_doc = index_v[v]

        if version_doc.needs_import? model_v[v]
          version_doc.import!(model_v[v], self, options)
        end

        sort_key = ebuild_order[v]
        version_doc.set_sort_key!(sort_key, self)

        if sort_key == 0
          self.useflags = version_doc.useflags
          save
        end
      end

      del_v.each do |v|
        index_v[v].delete
      end
    end
  end
end
