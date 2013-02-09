require 'socket'

require 'yggdrasil_common'

require 'yggdrasil_server/version'
require 'yggdrasil_server/help'
require 'yggdrasil_server/init'
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
      when 'daemon'
        Process.daemon
        YggdrasilServer.new.server(args[1..-1])
      when 'debug'
        args << '--debug'
        YggdrasilServer.new.server(args[1..-1])
      when 'help', 'h', '?'
        new(false).help(args[1..-1])
      when 'init'
        new(false).init_server(args[1..-1])
      when 'results'
        YggdrasilServer.new.results(args[1..-1])
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

  def server(args)
    args = parse_options(args, {'--debug'=>:debug?})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    puts "Start: yggdrasil server (port:#@port)"
    TCPServer.do_not_reverse_lookup = true
    s0 = TCPServer.open(@port.to_i)
    loop do
      sock = s0.accept
      msg = sock.gets # first line
      if msg && msg.chomp! != MESSAGE_QUIT
        msg.chomp!
        puts "RCV: #{msg}"
        msg_parts = msg.split
        if msg_parts.size != 0
          msg_cmd = msg_parts[0]
          part_names = MESSAGES[msg_cmd.to_sym]
          if (msg_parts.size - 1) == part_names.size
            # make hash of args
            msg_arg_hash = Hash.new
            (0...part_names.size).each do |i|
              msg_arg_hash[part_names[i]] = msg_parts[i+1]
            end

            # execute request (msg_cmd == method name)
            send msg_cmd, sock, msg_arg_hash
          else
            puts "fail: number of arguments is mismatch: #{msg}"
          end
        end
      end
      sock.close
      break if @options.has_key?(:debug?) && msg == MESSAGE_QUIT
    end
    s0.close # MESSAGE_QUIT
  end

  protected
  include YggdrasilCommon
end

