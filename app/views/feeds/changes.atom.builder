@feed_id ||= nil

atom_feed(id: atom_id(@feed_type, @feed_id, 'feed')) do |feed|
  feed.title @feed_title
  feed.updated !@changes.empty? ? @changes.first.created_at : Time.now

  feed.author do |author|
    author.name 'Gentoo Packages Database'
  end

  @changes.each do |change|
    atom = cp_to_atom change.category, change.package
    package = PackageRepository.find_by :atom, atom
    if package.nil?
      logger.warn "Package for change (#{change}) nil!"
      next
    end

    id = atom
    id += '-%s' % change.version if change[:version]
    id += '-%s' % change.arches.join(',') if change[:arches]

    feed.entry(
      change,
      id: atom_id(@feed_type, @feed_id, id),
      url: absolute_link_to_package(atom)) do |entry|
      entry.updated change.created_at.to_datetime.rfc3339

      case @feed_type
      when :added
        entry.title(t :feed_added_title,
                      atom: atom,
                      description: package.description)
        entry.content(t :feed_added_content,
                        atom: atom,
                        arches: package.latest_version.keywords.join(', '))
      when :updated
        entry.title(t :feed_updated_title,
                      atom: atom_add_version(atom, change.version),
                      description: package.description)
        entry.content(t :feed_updated_content,
                        atom: change.version)
      when :stable
        entry.title(t :feed_stable_title,
                      atom: atom_add_version(atom, change.version),
                      description: package.description)
        entry.content(t :feed_stable_content,
                        atom: atom,
                        arches: change.arches.join(', '))
      when :keyworded
        entry.title(t :feed_keyworded_title,
                      atom: atom_add_version(atom, change.version),
                      description: package.description)
        entry.content(t :feed_keyworded_content,
                        atom: atom,
                        arches: change.arches.join(', '))
      end
    end
  end
end
