module UseflagsHelper
  def annotate_useflag_description(str)
    sanitize(str.gsub(/<pkg>([^<]+)<\/pkg>/) { pkg=$~[1] ; link_to(pkg, slf(package_path(pkg))) }, tags: ['a'], attributes: ['href'])
  end
end
