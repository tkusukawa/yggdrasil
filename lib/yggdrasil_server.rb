require 'socket'

require "yggdrasil_common"

require "yggdrasil_server/init_server"
require "yggdrasil_server/get_repo"

class YggdrasilServer
  MESSAGES = {
      "get_repo" => [],
      "get_ro_id_pw" => [],
      "put_result" => [:hostname]
  }

  def initialize(exist_config = true)
    @base_cmd = File::basename($0)
    @current_dir = `readlink -f .`.chomp
    @config_dir = "#{ENV["HOME"]}/.yggdrasil"
    @server_config_file = "#@config_dir/server_config"
    @results_dir = "#@config_dir/results"

    return unless exist_config
    configs = read_config(@server_config_file)
    error "need 'port' in config file" unless (@port = configs[:port])
    error "need 'repo' in config file" unless (@repo = configs[:repo])
    @ro_username = configs[:ro_username]
    @ro_password = configs[:ro_password]
  end

  def server(args)
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    puts "Start: yggdrasil server (port:#{@port})"
    s0 = TCPServer.open(@port.to_i)
    loop do
      sock = s0.accept
      msg = sock.gets # first line
      if msg
        msg.chomp!
        puts "RCV: #{msg}"
        msg_parts = msg.split
        msg_cmd = msg_parts[0]
        part_names = MESSAGES[msg_cmd]
        unless (msg_parts.size - 1) == part_names.size
          puts "fail: number of arguments is mismatch: #{msg}"
        else
          # make hash of args
          msg_arg_hash = Hash.new
          (0...part_names.size).each do |i|
            msg_arg_hash[part_names[i]] = msg_parts[i+1]
          end

          # execute request (msg_cmd == method name)
          send msg_cmd, sock, msg_arg_hash
        end
      end
      sock.close
    end
    s0.close # never enter here
  end

  protected
  include YggdrasilCommon

end

