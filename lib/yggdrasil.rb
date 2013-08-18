require 'fileutils'

require 'yggdrasil_common'

require 'yggdrasil/version'
require 'yggdrasil/help'
require 'yggdrasil/init'
require 'yggdrasil/add'
require 'yggdrasil/commit'
require 'yggdrasil/cleanup'
require 'yggdrasil/diff'
require 'yggdrasil/list'
require 'yggdrasil/log'
require 'yggdrasil/update'
require 'yggdrasil/check'

class Yggdrasil

  def Yggdrasil.command(args, input = nil)
    $stdin = StringIO.new(input) if input != nil
    ENV['LANG'] = 'en_US.UTF-8'

    if args.size == 0
      new(false).help([])
      return
    end
    case args[0]
      when 'add'
        new.add(args[1..-1])
      when 'check', 'c', 'status', 'stat', 'st'
        new.check(args[1..-1])
      when 'cleanup'
        new.cleanup(args[1..-1])
      when 'commit', 'ci'
        new.commit(args[1..-1])
      when 'diff', 'di'
        new.diff(args[1..-1])
      when 'help', '--help', 'h', '-h', '?'
        new(false).help(args[1..-1])
      when 'init'
        new(false).init(args[1..-1])
      when 'list', 'ls'
        new.list(args[1..-1])
      when 'log'
        new.log(args[1..-1])
      when 'update', 'up', 'revert'
        new.update(args[1..-1])
      when 'version', '--version', '-v'
        new(false).version
      else
        $stderr .puts "Unknown subcommand: '#{args[0]}'"
        exit 1
    end
  end

  def initialize(exist_config = true)
    @base_cmd = File::basename($0)
    @current_dir = `pwd`.chomp
    @config_dir = "#{ENV['HOME']}/.yggdrasil"
    @config_file = "#{@config_dir}/config"
    @mirror_dir = "#{@config_dir}/mirror"
    @checker_dir = "#{@config_dir}/checker"
    @checker_result_dir = "#{@config_dir}/checker_result"

    return unless exist_config
    configs = read_config(@config_file)
    error 'need "path" in config file' unless (ENV['PATH'] = configs[:path])
    error 'need "svn" in config file' unless (@svn = configs[:svn])
    error 'need "repo" in config file' unless (@repo = configs[:repo])
    @anon_access = (configs[:anon_access] == 'read')
    @options ||= Hash.new
    @options[:server] = configs[:server] if configs.has_key?(:server)
  end

  protected
  include YggdrasilCommon

  def sync_mirror(target_paths)
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
        f = '/'+target_relatives[-1]
        error "no such file of directory:#{f}" unless File.exist?(f)
      end
    end

    updates = Array.new
    @target_file_num = 0
    FileUtils.cd @mirror_dir do
      files = Array.new
      cmd = "#{@svn} ls #{@repo} -R --no-auth-cache --non-interactive"
      cmd += username_password_options_to_read_repo
      out = system3(cmd)
      ls_files = out.split(/\n/)
      target_relatives.each do |target_relative|
        ls_files.each do |ls_file|
          files << ls_file if ls_file.match("^#{target_relative}")
        end
        cmd = "#{@svn} update --no-auth-cache --non-interactive"
        cmd += " -r #{@options[:revision]}" if @options.has_key?(:revision)
        cmd += username_password_options_to_read_repo
        cmd += ' '+target_relative
        system3(cmd)
        cmd = "#{@svn} status -q --no-auth-cache --non-interactive"
        cmd += username_password_options_to_read_repo
        cmd += ' '+target_relative
        out = system3(cmd)
        out.split(/\n/).each do |line|
          files << $1 if /^.*\s(\S+)\s*$/ =~ line
        end
      end
      files.sort!
      files.uniq!
      @target_file_num = files.size
      files.each do |file|
        if !File.exist?("/#{file}")
          system3 "#{@svn} delete #{file} --force" +
                      ' --no-auth-cache --non-interactive'
        elsif File.file?("/#{file}")
          if !File.exist?("#{@mirror_dir}/#{file}")
            cmd = "#{@svn} revert #{file}"
            system3 cmd
          end
          FileUtils.copy_file "/#{file}", "#{@mirror_dir}/#{file}"
          #`cp -fd /#{file} #@mirror_dir/#{file}`
        end
      end
      cmd = "#{@svn} status -qu --no-auth-cache --non-interactive"
      cmd += username_password_options_to_read_repo
      out = system3(cmd)
      out.split(/\n/).each do |line|
        next if /^Status against revision/ =~ line
        if /^(.).*\s(\S+)\s*$/ =~ line
          stat = $1
          file = $2
          files.each do |target|
            if file =~ /^#{target}/ || target =~ /^#{file}/
              updates << [stat, file]
              break
            end
          end
        end
      end
    end
    updates.sort.uniq
  end

  def confirm_updates(updates, yes_no=%w{Y n})
    Signal.trap('INT') {
      puts
      exit 1
    }
    display_list = true
    until @options.has_key?(:non_interactive?)
      puts
      if display_list
        (0...updates.size).each do |i|
          puts "#{i}:#{updates[i][0]} #{updates[i][1]}"
        end
        display_list = false
      end
      print "OK? [#{yes_no[0]}|#{yes_no[1]}|<num to diff>]: "
      res = $stdin.gets
      puts
      return nil unless res
      res.chomp!
      break if res == yes_no[0]
      return nil if res == yes_no[1]
      if /^\d+$/ =~ res && updates[res.to_i]
        yield updates[res.to_i][1]
      else
        display_list = true
      end
    end
    # res == 'Y'
    confirmed_updates = Array.new
    updates.each do |e|
      confirmed_updates << e[1]
    end
    confirmed_updates.sort.uniq
  end

  def username_password_options_to_read_repo
    if @options.has_key?(:ro_password)
      " --username #{@options[:ro_username]} --password #{@options[:ro_password]}"
    else
      ''
    end
  end

  def get_user_pass_if_need_to_read_repo
    unless @anon_access
      get_server_config if !@options.has_key?(:ro_username) && @options.has_key?(:server)
      input_user_pass unless @options.has_key?(:ro_password)
    end
    @options[:ro_username] = @options[:username] if @options.has_key?(:username)
    @options[:ro_password] = @options[:password] if @options.has_key?(:password)
  end

  def get_server_config(need_repo = false)
    if /^(.+):(\d+)$/ =~ @options[:server]
      host = $1
      port = $2

      if need_repo
        # get repo
        sock = TCPSocket.open(host, port)
        error "can not connect to server: #{host}:#{port}" if sock.nil?
        sock.puts 'get_repo'
        rcv = sock.gets
        error 'can not get repo from server' if rcv.nil?
        @options[:repo] = rcv.chomp
        sock.close
      end

      #get read-only username/password
      sock = TCPSocket.open(host, port)
      error "can not connect to server: #{host}:#{port}" if sock.nil?
      sock.puts('get_ro_id_pw')
      username = sock.gets
      unless username.nil?
        @options[:ro_username] = username.chomp
        password = sock.gets
        error 'can not get ro_password' if password.nil?
        @options[:ro_password] = password.chomp
      end
      sock.close
    else
      error "invalid host:port '#{@options[:server]}'"
    end
  end

  def exec_checker
    # execute checker
    `rm -rf #{@checker_result_dir}`
    Dir.mkdir @checker_result_dir, 0755
    if File.exist?(@checker_dir)
      Find.find(@checker_dir) do |file|
        if File.file?(file) && File.executable?(file)
          if file =~ %r{^#{@checker_dir}(.*)$}
            file_body = $1
            system3("#{file} > #{@checker_result_dir}#{file_body}")
          end
        end
      end
    end

    # add checker script and checker result
    result_files = Array.new
    Find.find(@checker_dir) do |f|
      result_files << f if File.file?(f) && File.executable?(f)
    end
    Find.find(@checker_result_dir) do |f|
      result_files << f if File.file?(f)
    end
    if result_files.size != 0
      stdout = $stdout
      $stdout = StringIO.new
      self.class.new.add result_files
      $stdout = stdout
    end
  end
end
