require 'socket'

require 'yggdrasil_common'

require 'yggdrasil_server/version'
require 'yggdrasil_server/help'
require 'yggdrasil_server/init'
require 'yggdrasil_server/server'
require 'yggdrasil_server/results'

require 'yggdrasil_server/get_repo'
require 'yggdrasil_server/get_ro_id_pw'
require 'yggdrasil_server/put_result'

class YggdrasilServer
  MESSAGE_QUIT = 'quit'
  MESSAGES = {
      :get_repo => [],
      :get_ro_id_pw => [],
      :put_result => [:hostname],
  }

  def YggdrasilServer.command(args, input = nil)
    $stdin = StringIO.new(input) if input != nil
    ENV['LANG'] = 'en_US.UTF-8'

    if args.size == 0
      new(false).help([])
      return
    end
    case args[0]
      when 'daemon', '-d'
        Process.daemon
        YggdrasilServer.new.server(args[1..-1])
      when 'debug', '--debug'
        args << '--debug'
        YggdrasilServer.new.server(args[1..-1])
      when 'help', '--help', 'h', '-h', '?'
        new(false).help(args[1..-1])
      when 'init'
        new(false).init_server(args[1..-1])
      when 'results', 'res'
        YggdrasilServer.new.results(args[1..-1])
      when 'version', '--version', '-v'
        new(false).version
      else
        $stderr .puts "Unknown subcommand: '#{args[0]}'"
        exit 1
    end
  end

  def initialize(exist_config = true)
    @base_cmd = File::basename($0)
    @current_dir = `readlink -f .`.chomp
    @config_dir = "#{ENV['HOME']}/.yggdrasil"
    @server_config_file = "#@config_dir/server_config"
    @results_dir = "#@config_dir/results"

    return unless exist_config
    configs = read_config(@server_config_file)
    error 'need "port" in config file' unless (@port = configs[:port])
    error 'need "repo" in config file' unless (@repo = configs[:repo])
    @ro_username = configs[:ro_username] if configs.has_key?(:ro_username)
    @ro_password = configs[:ro_password] if configs.has_key?(:ro_password)
  end

  protected
  include YggdrasilCommon
end
