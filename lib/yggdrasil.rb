require 'fileutils'
require "open3"
require "yggdrasil/version"
require "yggdrasil/help"
require "yggdrasil/init"
require "yggdrasil/add"
require "yggdrasil/commit"
require "yggdrasil/cleanup"
require "yggdrasil/diff"
require "yggdrasil/list"
require "yggdrasil/log"
require "yggdrasil/status"
require "yggdrasil/update"
require "yggdrasil/revert"

class Yggdrasil

  def Yggdrasil.command(args, input = nil)
    $stdin = StringIO.new(input) if input != nil
    ENV['LANG'] = 'en_US.UTF-8'

    if args.size == 0
      Yggdrasil::help([])
      return
    end
    case args[0]
      when 'add'
        new.add(args[1..-1])
      when 'cleanup'
        new.cleanup(args[1..-1])
      when 'commit', 'ci'
        new.commit(args[1..-1])
      when 'diff', 'di'
        new.diff(args[1..-1])
      when 'help', 'h', '?'
        help(args[1..-1])
      when 'init'
        new(false).init(args[1..-1])
      when 'list', 'ls'
        new.list(args[1..-1])
      when 'log'
        new.log(args[1..-1])
      when 'status', 'stat', 'st'
        new.status(args[1..-1])
      when 'revert'
        new.revert(args[1..-1])
      when 'update'
        new.update(args[1..-1])
      when 'version', '--version'
        version
      else
        error "Unknown subcommand: '#{args[0]}'"
    end
  end

  # @param [String] cmd
  def Yggdrasil.system3(cmd, err_exit=true)
    out = `#{cmd} 2>&1`
    stat = $?

    unless stat.success?
      return nil unless err_exit
      $stderr.puts "#{CMD} error: command failure: #{cmd}"
      $stderr.puts "command output:"
      $stderr.puts out
      exit stat.exitstatus
    end
    return out
  end

  protected
  # @param [String] msg
  def Yggdrasil.error(msg)
    $stderr.puts "#{CMD} error: #{msg}"
    $stderr.puts
    exit 1
  end

  def parse_options(args, valid_params)
    valid_params['--debug'] = :debug? # common
    @options ||= Hash.new
    pos = 0
    while args.size > pos
      if valid_params.has_key?(args[pos])
        option_note = args[pos]
        option_key = valid_params[option_note]
        args = args[0...pos]+args[pos+1..-1]
        if option_key.to_s[-1,1] == '?'
          @options[option_key] = true
        else
          error "Not enough arguments provided: #{option_note}" unless args.size > pos
          option_value = args[pos].dup
          args = args[0...pos]+args[pos+1..-1]
          @options[option_key] = option_value
        end
        next
      end
      pos += 1
    end
    args
  end

  def input_user_pass
    until @options.has_key?(:username) do
      error "Can't get username or password" if @options.has_key?(:non_interactive?)
      print "Input svn username: "
      input = $stdin.gets
      @options[:username] = input.chomp
    end
    until @options.has_key?(:password) do
      error "Can't get username or password" if @options.has_key?(:non_interactive?)
      print "Input svn password: "
      #input = `sh -c 'read -s hoge;echo $hoge'`
      system3 'stty -echo', false
      input = $stdin.gets
      system3 'stty echo', false
      puts
      @options[:password] = input.chomp
    end
  end

  def initialize(exist_config = true)
    @current_dir = `readlink -f .`.chomp
    @config_dir = "#{ENV["HOME"]}/.yggdrasil"
    @config_file = "#@config_dir/config"
    @mirror_dir = "#@config_dir/mirror"

    return unless exist_config
    configs = read_config
    ENV["PATH"] = configs[:path]
    @svn = configs[:svn]
    @repo = configs[:repo]
    @anon_access = (configs[:anon_access] == 'read')
  end

  # load config value from config file
  def read_config
    configs = Hash.new
    begin
      File.open(@config_file) do |file|
        l = 0
        while (line = file.gets)
          l += 1
          next if /^\s*#.*$/ =~ line  # comment line
          if /^\s*(\S+)\s*=\s*(\S+).*$/ =~ line
            key, val = $1, $2
            key.gsub!(/-/, '_')
            configs[key.to_sym] = val
          else
            error "syntax error. :#@config_file(#{l})"
          end
        end
      end
    rescue
      error "can not open config file: #@config_file"
    end
    configs
  end

  def sync_mirror
    updates = Array.new
    FileUtils.cd @mirror_dir do
      cmd = "#@svn ls #@repo -R --no-auth-cache --non-interactive"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
      out = system3(cmd)
      files = out.split(/\n/)
      cmd = "#@svn status -q --no-auth-cache --non-interactive"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
      out = system3(cmd)
      out.split(/\n/).each do |line|
        files << $1 if /^.*\s(\S+)\s*$/ =~ line
      end
      files.sort!
      files.uniq!
      files.each do |file|
        if !File.exist?("/#{file}")
          system3 "#@svn delete #{file} --force" +
                      " --no-auth-cache --non-interactive"
        elsif File.file?("/#{file}")
          if !File.exist?("#@mirror_dir/#{file}")
            cmd = "#@svn revert #{file}"
            cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
            system3 cmd
          end
          FileUtils.copy_file "/#{file}", "#@mirror_dir/#{file}"
        end
      end
      cmd = "#@svn status -q --no-auth-cache --non-interactive"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
      out = system3(cmd)
      out.split(/\n/).each do |line|
        updates << $1 if /^.*\s(\S+)\s*$/ =~ line
      end
    end
    updates
  end

  def select_updates(updates, target_paths)

    target_relatives = Array.new
    if  target_paths.size == 0
      target_relatives << @current_dir.sub(%r{^/*},'')
    else
      target_paths.each do |path|
        if %r{^/} =~ path
          target_relatives << path.sub(%r{^/*},'') # cut first '/'
        else
          target_relatives << @current_dir.sub(%r{^/*},'') + '/' + path
        end
      end
    end

    # search updated files in the specified dir
    cond = '^'+target_relatives.join('|^') # make reg exp
    matched_updates = Array.new
    updates.each do |update|
      matched_updates << update if update.match(cond)
    end

    # search parent updates of matched updates
    parents = Array.new
    updates.each do |update|
      matched_updates.each do |matched_update|
        parents << update if matched_update.match("^#{update}/")
      end
    end
    matched_updates += parents
    matched_updates.sort.uniq
  end

  def confirm_updates(updates)
    until @options.has_key?(:non_interactive?)
      puts
      (0...updates.size).each do |i|
        puts "#{i}:#{updates[i]}"
      end
      print "OK? [Y|n|<num to diff>]:"
      res = $stdin.gets
      return nil unless res
      res.chomp!
      return nil if res == 'n'
      break if res == 'Y'
      next unless updates[res.to_i]
      if /^\d+$/ =~ res
        yield updates[res.to_i]
      end
    end
    # res == 'Y'
    updates
  end

  def method_missing(action, *args)
    Yggdrasil.__send__ action, *args
  end
end
