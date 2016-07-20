class Portage::Util::Mask
  attr_accessor :author, :date, :reason
  attr_reader :atoms

  def initialize(author, date, reason, atoms)
    @author = author
    @date = date
    @reason = reason
    @atoms = atoms
  end

  def add_atom(atom)
    @atoms << atom
  end

  def to_s
    "<Mask @author='#{@author}' @reason='#{@reason[0..50]}' @atoms=[#{@atoms.join ','}]>"
  end

  def to_hash
    {
      author: author,
      date: date,
      reason: reason,
      atoms: atoms
    }
  end
end
