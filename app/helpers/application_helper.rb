module ApplicationHelper
  def cp_to_atom(category, package)
    '%s/%s' % [category, package]
  end

  def atom_add_version(atom, version)
    '%s-%s' % [atom, version]
  end

  # Generates a somewhat sensible atom ID
  def atom_id(*args)
    ['tag:packages.gentoo.org,2015-10-03', args].flatten.compact.join ':'
  end

  def alternate_feed_link(url, description, mime = 'application/atom+xml')
    tag :link,
        rel: 'alternate',
        href: url,
        title: description,
        type: mime
  end

  # Renders a label displaying the first letters of the components of a string
  def abbreviated_label(items, css_class, message_id)
    return '' if items.nil? || items.empty?

    letters = strip_conditionals(items).map { |r| r[0].upcase }.uniq

    content_tag :span,
                letters.join(', '),
                class: 'label %s' % css_class,
                title: t(message_id, list: items.join(' '))
  end

  def last_import_start
    Rails.cache.fetch(::KK_CACHE_LAST_IMPORT)
  end

  def i18n_date(date, format = '%a, %e %b %Y %H:%M')

    date = Time.parse(date).utc if date.is_a? String

    content_tag :span,
                l(date, format: format),
                class: 'kk-i18n-date',
                :'data-utcts' => date.strftime('%s'),
                :'data-format' => format.to_s,
                title: date.to_formatted_s(:rfc822)
  end

  def kk_changelog
    File.read('CHANGES.md')
  end
end
