# Helpers for displaying package models
module PackagesHelper
  def restrict_label(version)
    abbreviated_label version.restrict,
                      'label-danger kk-restrict-label',
                      :restrict_tooltip
  end

  def properties_label(version)
    abbreviated_label version.properties,
                      'label-info kk-properties-label',
                      :properties_tooltip
  end

  def version_labels(version)
    capture do
      concat restrict_label(version)
      concat properties_label(version)
    end
  end

  def annotate_license_str(str)
    str.split(/\s/).map do |license|
      if license[0] =~ /[[:alpha:]]/ && !license.end_with?('?')
        link_to_license_text license
      else
        h license
      end
    end.join(' ').html_safe
  end

	# This parses commit messages for GLEP66 style bug annotations.
	# Bug: https://bugs.gentoo.org/NNNNNN
	# Closes: https://bugs.gentoo.org/NNNNNN
	def glep66_bugs(commit_msg)
		bugs_list = []
		commit_msg.each_line do |line| {
			bugno = line[/(Bug\:|Closes\:)\s+https:\/\/bugs\.gentoo\.org\/(\d+)/, 1]
			bugs_list << "https://bugs.gentoo.org/#{bugno}" if !bugno.nil?
		}
		bugs_list
	end

  def annotate_bugs(str)
    annotated_str = str.gsub(/([bB]ug\s+|[bB]ug\s+#|#)(\d+)/) do
      link_to_bug("#{$1}#{$2}", $2)
    end

    sanitize(annotated_str, tags: ['a'], attributes: ['href'])
  end

  # Filters duplicate masks
  def filter_masks(versions)
    masks = {}

    versions.each do |version|
      version.masks.each do |mask|
        masks[mask['reason']] = mask
      end
    end

    masks.values
  end

  def version_slot(slot, subslot = nil)
    title = "subslot #{subslot}" if subslot && !subslot.empty?

    content_tag :span,
                sanitize('&#x2008;:&#x2008;%s' % slot),
                class: 'kk-slot',
                title: title
  end

  # Returns a list of members belonging to a project
  def project_members(project)
    Portage::Util::Projects.cached_instance.inherited_members(project)
  end

  # Tries to find a matching changelog entry for a change object
  def matching_changelog_entry(change)
    changelog = Rails.cache.fetch("changelog/#{cp_to_atom(change.category, change.package)}", expires_in: 10.minutes) do
      Portage::Util::History.for(change.category, change.package, 5)
    end

    changelog.each do |changelog_entry|
      if changelog_entry[:files][:added].include?('%s-%s.ebuild' % [change.package, change.version])
        return changelog_entry
      end
    end

    nil
  end
end
