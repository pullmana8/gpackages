# Provides low-level access to a mask file
class Portage::Util::Maskfile
  attr_reader :masks

  def initialize(path)
    @path = path
    @masks = []
    parse!
  end

  def parse!
    File.read(@path).split("\n\n").each do |raw_mask|
      comments = []
      atoms = []

      raw_mask.each_line do |line|
        line.strip!

        if line.start_with? '#'
          comments << line
        else
          atoms << line unless line == ''
        end
      end

      # Skip examples or other comment-only entries
      next if atoms.empty?

      author = nil
      date = nil

      if comments.first =~ /^#\s+(.*)\s+<([^>]+)>\s\(([^)]+)\)/
        author = '%s <%s>' % [$1, $2]
        date = $3
      end

      # Strip the newlines, we don't want to carry over the ASCII art
      reason = comments[1..-1].map { |l| l.gsub(/^# /, '') }.join ' '

      @masks << Portage::Util::Mask.new(author, date, reason, atoms)
    end
  end
end
