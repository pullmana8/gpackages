require 'open3'

class Kkuleomi::Util::Exec
  def initialize(command)
    @cmd = command
  end

  def env(key, value)
    @env ||= {}
    @env[key] = value

    self
  end

  def args(*arguments)
    @args = arguments

    self
  end

  def in(chdir)
    @chdir = chdir

    self
  end

  def run
    args = nil

    if @env.is_a?(Hash) && !@env.empty?
      args = [@env, @cmd]
    else
      args = @cmd
    end

    opts = {}
    opts[:chdir] = @chdir if @chdir

    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(args, *(@args || []), opts)

    @ran = true
    self
  end

  def exit_status
    run unless @ran
    @wait_thr.value
  end

  def stdout
    run unless @ran
    @stdout.read
  end

  def stderr
    run unless @ran
    @stderr.read
  end

  class << self
    def cmd(command)
      new(command)
    end
  end
end
