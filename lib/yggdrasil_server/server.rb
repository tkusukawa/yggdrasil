class YggdrasilServer

  def server(args)
    parse_options(args, {'--debug'=>:debug?})
    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    ctime = Time.now
    $stdout.printf "Start: yggdrasil server (port:#{@port})[%04d-%02d-%02d %02d:%02d:%02d.%03d]\n",
           ctime.year, ctime.month, ctime.day, ctime.hour, ctime.min, ctime.sec, (ctime.usec/1000).round
    $stdout.flush
    TCPServer.do_not_reverse_lookup = true
    s0 = TCPServer.open(@port.to_i)
    loop do
      sock = s0.accept
      msg = sock.gets # first line
      ctime = Time.now
      if msg && msg.chomp! != MESSAGE_QUIT
        msg.chomp!
        $stdout.printf "RCV[%04d-%02d-%02d %02d:%02d:%02d.%03d](#{sock.peeraddr[3]}): #{msg}\n",
               ctime.year, ctime.month, ctime.day, ctime.hour, ctime.min, ctime.sec, (ctime.usec/1000).round
        $stdout.flush
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
            $stdout.flush
          end
        end
      end
      sock.close
      if @options.has_key?(:debug?) && msg == MESSAGE_QUIT
        ctime = Time.now
        $stdout.printf "Quit: yggdrasil server (port:#{@port})[%04d-%02d-%02d %02d:%02d:%02d.%03d]\n",
                       ctime.year, ctime.month, ctime.day, ctime.hour, ctime.min, ctime.sec, (ctime.usec/1000).round
        $stdout.flush
        break
      end
    end
    s0.close # MESSAGE_QUIT
  end
end
