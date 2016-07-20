module PortageHelper
  # Strips condition constructs ("foo? ()") from a Portage definition
  def strip_conditionals(ary)
    ary.reject do |item|
      (not item[0] =~ /[[:alpha:]]/) or item.end_with? '?'
    end
  end
end
