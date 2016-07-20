module Portage
  module Util
    class Masks
      class << self
        # Updates the mask cache
        def update!
          mask_hash = {}
          profiles_base_dir = File.join(KKULEOMI_PORTDIR, 'profiles')

          add_global_masks(mask_hash, profiles_base_dir)
          add_arch_masks(mask_hash, profiles_base_dir)

          @masks = mask_hash
        end

        def masks
          @masks || update!
        end

        # Filters all masks for masks applying to this ebuild
        #
        # @param [Portage::Repository::Ebuild] ebuild Ebuild model
        def for(ebuild)
          ebuild_masks = masks[ebuild.to_cp]
          result = []
          return result unless ebuild_masks

          ebuild_masks.each do |mask|
            matches = false

            mask[:atoms].each do |atom|
              matches = true if Portage::Util::Atoms.matches?(atom, ebuild.version, ebuild.metadata[:slot])
            end

            result << mask if matches
          end

          result
        end

        private

        # Adds the globally set masks (profiles{,base}/package.mask) to the new mask hash
        def add_global_masks(mask_hash, profiles_base_dir)
          mask_files = [
            File.join(profiles_base_dir, 'package.mask'),
            File.join(profiles_base_dir, 'base', 'package.mask')
          ]

          mask_files.each do |mask_file|
            Portage::Util::Maskfile.new(mask_file).masks.each do |mask|
              add_mask(mask_hash, mask, '*')
            end
          end
        end

        # Adds all arch-specific masks to the new mask hash
        def add_arch_masks(mask_hash, profiles_base_dir)
          Dir.glob(File.join(profiles_base_dir, 'arch', '*', 'package.mask')) do |mask_file|
            arch = mask_file.split('/')[-2]

            Portage::Util::Maskfile.new(mask_file).masks.each do |mask|
              add_mask(mask_hash, mask, arch)
            end
          end
        end

        # Adds a single mask entry
        def add_mask(mask_list, mask, arch = '*')
          mask_hash = mask.to_hash.merge(arches: [arch])

          mask.atoms.each do |atom|
            atom = Portage::Util::Atoms.parse(atom)
            insert_or_append_mask(mask_list, atom, mask_hash)
          end
        rescue => e
          Rails.logger.warn { "Parsing mask #{mask.inspect} on arch #{arch} failed: #{e.message}" }
        end

        def insert_or_append_mask(mask_list, atom, mask)
          key = atom[:category] + '/' + atom[:package]

          if mask_list.key? key
            append_mask(mask_list, key, mask)
          else
            mask_list[key] = [mask]
          end
        end

        def append_mask(mask_list, key, mask)
          mask_list[key].each do |existing_mask|
            next unless existing_mask[:reason] == mask[:reason]

            if existing_mask[:arches] == ['*'] || mask[:arches] == ['*']
              existing_mask[:arches] = ['*']
            else
              existing_mask[:arches] += mask[:arches]
              existing_mask[:arches].uniq!
            end
          end
        end
      end
    end
  end
end
