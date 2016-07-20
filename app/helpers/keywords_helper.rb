# Helper methods for dealing with package version KEYWORDS
module KeywordsHelper
  # Renders an icon for a keyword status
  def keyword_icon_tag(keyword)
    css_class = KK_KEYWORD_ICON[keyword]

    if css_class
      content_tag :span,
                  '',
                  class: ['octicon', css_class]
    else
      ''
    end
  end

  # Retrieves the CSS class for a keyword
  def keyword_class(keyword)
    KK_KEYWORD_CLASS[keyword] || nil
  end

  # Displays a keyword icon plus text-mdoe browser fallback
  def keyword_icon(keyword, arch)
    capture do
      concat keyword_icon_tag(keyword)
      concat keyword_fallback_tag(keyword, arch)
    end
  end

  # Renders a keyword as a familiar string
  def keyword_string(keyword, arch)
    case keyword
    when :stable
      arch
    when :testing
      '~%s' % arch
    when :unavailable
      '-%s' % arch
    when :masked
      '[M]%s' % arch
    else
      '?%s' % arch
    end
  end

  def keyword_fallback_tag(keyword, arch)
    content_tag :span,
                keyword_string(keyword, arch),
                class: 'sr-only'
  end

  def verbalize_version_visibility(version, arch)
    keyword = t(KK_KEYWORD_VERBALIZATION[version.keyword(arch)])

    keyword_str = keyword
    keyword_str = '%s (%s)' % [
      t(KK_KEYWORD_VERBALIZATION[:masked]),
      keyword
    ] if version.is_masked?

    t 'keyword_tooltip',
      version: version.version,
      keyword: keyword_str,
      arch: arch
  end

  def keyword_cell(version, arch, large_separator = false)
    effective_keyword = version.effective_keyword arch

    css_class = ['kk-keyword']
    css_class << 'kk-cell-sep-right' if large_separator
    css_class << keyword_class(effective_keyword)

    content_tag :td,
                keyword_icon(effective_keyword, arch),
                class: css_class,
                title: verbalize_version_visibility(version, arch)
  end

  def keyword_label(version, arch)
    effective_keyword = version.effective_keyword arch

    css_class = ['label']
    css_class << keyword_class(effective_keyword)

    content_tag :span,
                keyword_string(effective_keyword, arch),
                class: css_class,
                title: verbalize_version_visibility(version, arch)
  end
end
