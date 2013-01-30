require 'fileutils'

require "yggdrasil_common"
require "yggdrasil_server"

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
require "yggdrasil/check"

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
      when 'check', 'c'
        new.check(args[1..-1])
      when 'cleanup'
        new.cleanup(args[1..-1])
      when 'commit', 'ci'
        new.commit(args[1..-1])
      when 'diff', 'di'
        new.diff(args[1..-1])
      when 'help', 'h', '?'
        new(false).help(args[1..-1])
      when 'init'
        new(false).init(args[1..-1])
      when 'init-server'
        YggdrasilServer.new(false).init_server(args[1..-1])
      when 'list', 'ls'
        new.list(args[1..-1])
      when 'log'
        new.log(args[1..-1])
      when 'results'
        YggdrasilServer.new.results(args[1..-1])
      when 'revert'
        new.revert(args[1..-1])
      when 'server'
        YggdrasilServer.new.server(args[1..-1])
      when 'status', 'stat', 'st'
        new.status(args[1..-1])
      when 'update'
        new.update(args[1..-1])
      when 'version', '--version'
        new(false).version
      else
        $stderr .puts "Unknown subcommand: '#{args[0]}'"
        exit 1
    end
  end

  def initialize(exist_config = true)
    @base_cmd = File::basename($0)
    @current_dir = `readlink -f .`.chomp
    @config_dir = "#{ENV["HOME"]}/.yggdrasil"
    @config_file = "#@config_dir/config"
    @mirror_dir = "#@config_dir/mirror"
    @checker_dir = "#@config_dir/checker"
    @checker_result_dir = "#@config_dir/checker_result"
    @server_config_file = "#@config_dir/server_config"

    return unless exist_config
    configs = read_config(@config_file)
    error "need 'path' in config file" unless (ENV["PATH"] = configs[:path])
    error "need 'svn' in config file" unless (@svn = configs[:svn])
    error "need 'repo' in config file" unless (@repo = configs[:repo])
    @anon_access = (configs[:anon_access] == 'read')
  end


  protected
  include YggdrasilCommon

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
end
