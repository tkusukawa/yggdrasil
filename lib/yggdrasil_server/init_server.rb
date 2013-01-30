class YggdrasilServer

  # @param [Array] args
  def init_server(args)

    args = parse_options(args,
                         {'--port'=>:port, '--repo'=>:repo,
                          '--ro-username'=>:username, '--ro-password'=>:password})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    if !@options.has_key?(:username) && @options.has_key?(:password)
      error "--ro-password option need --ro-username, too."
    end

    until @options.has_key?(:port)
      print "Input tcp port number: "
      input = $stdin.gets
      error "can not input tcp port number" unless input

      input.chomp!
      unless %r{\d+} =~ input && input.to_i < 0x10000
        puts "ERROR: Invalid port number."
        redo
      end
      @options[:port] = input # string
    end

    until @options.has_key?(:repo)
      print "Input svn repo URL: "
      input = $stdin.gets
      error "can not input svn repo URL." unless input

      unless %r{^(http://|https://|file://|svn://)} =~ input
        puts "ERROR: Invalid URL."
        redo
      end
      @options[:repo] = input
    end
    @options[:repo].chomp!
    @options[:repo].chomp!('/')

    unless @options.has_key?(:username)
      puts "Input read-only username/password (clients use this to read repo)."
      puts "ATTENTION! username/password are stored to disk unencrypted!"
      input_user_pass
    end

    # make config file
    Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)
    File.open(@server_config_file, "w") do |f|
      f.write "port=#{@options[:port]}\n"\
              "repo=#{@options[:repo]}\n"
      if @options.has_key?(:username)
        f.write "ro_username=#{@options[:username]}\n"\
                "ro_password=#{@options[:password]}\n"
      end
    end
  end
end

