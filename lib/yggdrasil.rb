require "open3"
require "yggdrasil/version"
require "yggdrasil/help"
require "yggdrasil/init"
require "yggdrasil/add"
require "yggdrasil/commit"
require "yggdrasil/cleanup"
require "yggdrasil/diff"

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
        init(args[1..-1])
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

  protected
  # @param [String] msg
  def Yggdrasil.error(msg)
    puts "#{CMD} error: #{msg}"
    puts
    exit 1
  end

  # @param [String] cmd
  def Yggdrasil.exec_command(cmd, err_exit=true)
    out,stat = Open3.capture2e cmd
    unless stat.success?
      return nil unless err_exit
      puts "#{CMD} error: command failure: #{cmd}"
      puts
      exit stat.exitstatus
    end
    return out
  end

  def Yggdrasil.parse_options(args, valid_params)
    options = Hash.new
    pos = 0
    while args.size > pos
      if valid_params.has_key?(args[pos])
        option_note = args[pos]
        option_key = valid_params[option_note]
        args = args[0...pos]+args[pos+1..-1]
        if option_key.to_s[-1] == '?'
          options[option_key] = true
        else
          error "Not enough arguments provided: #{option_note}" unless args.size > pos
          option_value = args[pos]
          args = args[0...pos]+args[pos+1..-1]
          options[option_key] = option_value
        end
        next
      end
      pos += 1
    end
    return args, options
  end

  def Yggdrasil.input_user_pass(options)
    until options.has_key?(:username) do
      print "Input svn username: "
      input = $stdin.gets
      options[:username] = input.chomp
    end
    until options.has_key?(:password) do
      print "Input svn password: "
      #input = `sh -c 'read -s hoge;echo $hoge'`
      `stty -echo`
      input = $stdin.gets
      `stty echo`
      puts
      options[:password] = input.chomp
    end
    return options
  end

  def initialize

    @config = read_config
    ENV["PATH"] = @config[:path]
    @svn = @config[:svn]
    @repo = @config[:repo]
    @work_dir = `readlink -f .`.chomp
    @mirror_dir = ENV["HOME"]+"/.yggdrasil/mirror"
  end

  # load config value from config file
  def read_config
    @config=Hash.new
    begin
      config_file = open("#{ENV['HOME']}/.yggdrasil/config")
    rescue
      puts "#{CMD} error: can not open config file: #{ENV['HOME']}/.yggdrasil/config"
      exit 1
    end
    l = 0
    while (line = config_file.gets)
      l += 1
      next if /^\s*#.*$/ =~ line  # comment line
      if /^\s*(\S+)\s*=\s*(\S+).*$/ =~ line
        @config[$1.to_sym] = $2
      else
        puts "#{CMD} error: syntax error. :#{ENV['HOME']}/.yggdrasil/config(#{l})"
        exit 1
      end
    end
    config_file.close
    return @config
  end

  def sync_mirror(options)
    FileUtils.cd @mirror_dir do
      out = exec_command("#@svn ls --no-auth-cache --non-interactive"\
                           " --username '#{options[:username]}' --password '#{options[:password]}'"\
                           " --depth infinity #@repo")
      files = out.split(/\n/)
      out = exec_command("#@svn status -q --no-auth-cache --non-interactive"\
                           " --username '#{options[:username]}' --password '#{options[:password]}'")
      out.split(/\n/).each do |line|
        if /^.*\s(\S+)\s*$/ =~ line
          files.push($1)
        end
      end
      files.sort!
      files.uniq!
      paths=Array.new
      files.each do |file|
        absolute = '/'+file
        if !File.exist?(absolute)
          exec_command "#@svn delete --force --no-auth-cache --non-interactive"\
                       " #{file}"
        elsif File.file?(absolute)
          if !File.exist?(@mirror_dir+absolute)
            exec_command "#@svn revert --no-auth-cache --non-interactive #{file}"
          end
          FileUtils.copy_file absolute, @mirror_dir+absolute
        end
        paths.push absolute
      end
      return paths
    end
  end

  def method_missing(action, *args)
    Yggdrasil.__send__ action, *args
  end
end
