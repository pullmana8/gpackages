require 'time'

class Portage::Util::History
  class << self
    def update()
      return [] if KKULEOMI_DISABLE_GIT == true

      latest_commit_id = KKULEOMI_FIRST_COMMIT
      latest_commit = CommitRepository.n_sorted_by(1, "date", "desc").first

      unless latest_commit.nil?
        latest_commit_id = latest_commit.id
      end

      git = Kkuleomi::Util::Exec
          .cmd(KKULEOMI_GIT)
          .in(KKULEOMI_RUNTIME_PORTDIR)
          .args(
            'log', '--name-status', '--no-merges', '--date=iso8601', "--reverse",
            "#{latest_commit_id}..HEAD")
          .run

      raw_log, stderr, status = git.stdout, git.stderr, git.exit_status
      fail "Cannot get git log: #{stderr}" unless status == 0

      parse raw_log
    end

    private

    def parse(raw_log)

      count = raw_log.split("\n\ncommit ").slice(0, 10000).size

      raw_log.split("\n\ncommit ").slice(0, 10000).each do |raw_commit|

        commit_lines = raw_commit.lines

        _id = commit_lines.shift.gsub('commit ', '').strip

        commit_lines.shift =~ /^Author:\s+(.*) <([^>]*)>$/
        _author = $1
        _email = $2

        _date = Time.parse(commit_lines.shift[/^Date:\s+(.*)$/, 1]).utc

        commit_lines.shift
        _raw_message = []
        while (line = commit_lines.shift) != "\n" && !line.nil?
          _raw_message << line
        end

        _raw_files = commit_lines
        _files = {added: [], modified: [], deleted: []}
        _packages = []
        _raw_files.each do |file|
          mode, file = file.split "\t"

          if file.strip.split('/').size >= 3
            _packages <<  (file.strip.split('/')[0] + '/' + file.strip.split('/')[1])
          end

          case mode
            when 'M'
              _files[:modified] << file.strip
            when 'D'
              _files[:deleted] << file.strip
            when 'A'
              _files[:added] << file.strip
          end
        end


        commit = Commit.new
        commit.id = _id
        commit.author = _author
        commit.email = _email
        commit.date = _date
        commit.message = _raw_message.map { |l| l.strip }.join("\n")
        commit.files = _files
        commit.packages = _packages.to_set
        CommitRepository.save(commit)
      end

      if count >= 10000
        CommitsUpdateJob.perform_later
      end

    end
  end
end
