module LinksHelper
  # Slash-in-Link-Fix
  # Replaces the URLencoded slash with a proper slash
  def slf(input)
    input.gsub('%2F', '/')
  end

  def link_to_gitweb_commit(commitid)
    link_to commitid[0...8],
            gitweb_commit_url(commitid),
            title: commitid,
            class: 'kk-commit'
  end

  def gitweb_commit_url(commitid)
    'https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=%s' % commitid
  end

  def link_to_gitweb_ebuild_diff(name, commitid, cat, pkg)
    link_to name, 'https://gitweb.gentoo.org/repo/gentoo.git/diff/%s/%s/%s?id=%s' % [cat, pkg, name, commitid]
  end

  def link_to_license_text(license)
    link_to license, 'https://gitweb.gentoo.org/repo/gentoo.git/plain/licenses/%s' % license
  end

  def link_version_to_ebuild(version)
    ebuild_path = '%s/%s.ebuild' % [version.package, version.atom.split('/').last]
    link_to version.version, 'https://gitweb.gentoo.org/repo/gentoo.git/tree/%s' % ebuild_path, class: 'kk-ebuild-link'
  end

  def link_to_category(category)
    link_to category.name,
            category_path(category),
            title: category.description,
            'data-toggle' => 'tooltip',
            'data-placement' => 'right'
  end

  def link_to_package(atom)
    link_to atom, slf(package_path(atom))
  end

  def link_to_bug(str, bugid)
    link_to str, 'https://bugs.gentoo.org/show_bug.cgi?id=%s' % bugid
  end

  def absolute_link_to_package(atom)
    slf package_url(atom)
  end

  def feed_icon(url)
    content_tag :a,
                content_tag(:span, '', class: 'fa fa-fw fa-rss-square'),
                title: t(:atom_feed), href: url, class: 'kk-feed-icon'
  end
end
