class YggdrasilServer

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
      ctime = Time.now
      if msg && msg.chomp! != MESSAGE_QUIT
        msg.chomp!
        printf "RCV[%04d-%02d-%02d %02d:%02d:%02d.%03d](#{sock.peeraddr[3]}): #{msg}\n",
               ctime.year, ctime.month, ctime.day, ctime.hour, ctime.min, ctime.sec, (ctime.usec/1000).round
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
end
