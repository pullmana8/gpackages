require 'time'

class Portage::Util::History
  class << self
    def for(category, package, limit = 20)
      return [] if KKULEOMI_DISABLE_GIT == true

      files = "#{category}/#{package}/*.ebuild"
      git = Kkuleomi::Util::Exec
            .cmd(KKULEOMI_GIT)
            .in(KKULEOMI_RUNTIME_PORTDIR)
            .args(
              'log', '--name-status', '--no-merges', '--date=iso8601', "-n #{limit.to_i}",
              "#{KKULEOMI_FIRST_COMMIT}..HEAD", files)
            .run

      raw_log, stderr, status = git.stdout, git.stderr, git.exit_status
      fail "Cannot get git log: #{stderr}" unless status == 0

      parse raw_log
    end

    private

    def parse(raw_log)
      log_items = []

      raw_log.split("\n\ncommit ").each do |raw_commit|
        commit_lines = raw_commit.lines

        _id = commit_lines.shift.gsub('commit ', '').strip

        commit_lines.shift =~ /^Author:\s+(.*) <([^>]*)>$/
        _author = $1
        _email = $2

        _date = Time.parse(commit_lines.shift[/^Date:\s+(.*)$/, 1]).utc

        commit_lines.shift
        _raw_message = []
        while (line = commit_lines.shift) != "\n"
          _raw_message << line
        end

        _raw_files = commit_lines
        _files = {added: [], modified: [], deleted: []}
        _raw_files.each do |file|
          mode, file = file.split "\t"
          filename = file.strip.split('/').last

          case mode
            when 'M'
              _files[:modified] << filename
            when 'D'
              _files[:deleted] << filename
            when 'A'
              _files[:added] << filename
          end
        end

        log_items << {
          id: _id,
          author: _author,
          email: _email,
          date: _date,
          message: _raw_message.map { |l| l.strip }.join("\n"),
          files: _files
        }
      end

      log_items
    end
  end
end
