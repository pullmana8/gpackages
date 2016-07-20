module Portage::Ebuild
  # Exception thrown when an atom is invalid
  class InvalidAtomError < StandardError
  end

  # Exception thrown when a version string is invalid
  class InvalidVersionError < StandardError
  end
end
