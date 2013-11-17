class YggdrasilServer

  # @param [Array] args
  def init_server(args)

    parse_options(args,
                  {'--port'=>:port, '--repo'=>:repo,
                   '--ro-username'=>:ro_username, '--ro-password'=>:ro_password})
    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    if !@options.has_key?(:ro_username) && @options.has_key?(:ro_password)
      error '--ro-password option need --ro-username, too.'
    end

    until @options.has_key?(:port)
      print 'Input tcp port number: '
      input = $stdin.gets
      error 'can not input tcp port number' unless input

      input.chomp!
      unless %r{\d+} =~ input && input.to_i < 0x10000
        puts 'ERROR: Invalid port number.'
        redo
      end
      @options[:port] = input # string
    end

    until @options.has_key?(:repo)
      print 'Input svn repo URL: '
      input = $stdin.gets
      error 'can not input svn repo URL.' unless input

      unless %r{^(http://|https://|file://|svn://)} =~ input
        puts 'ERROR: Invalid URL.'
        redo
      end
      @options[:repo] = input
    end
    @options[:repo].chomp!
    @options[:repo].chomp!('/')
    unless @options[:repo] =~ /\{HOST\}/ || @options[:repo] =~ /\{host\}/
      error 'REPO must contain {HOST} or {host}'
    end


    unless @options.has_key?(:ro_password)
      puts 'Input read-only username/password (clients use this to read repo).'
      puts 'ATTENTION! username/password are stored to disk unencrypted!'
      input_user_pass
    end

    # make config file
    Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)
    File.open(@server_config_file, 'w') do |f|
      f.write "port=#{@options[:port]}\n"\
              "repo=#{@options[:repo]}\n"
      if @options.has_key?(:ro_password)
        f.write "ro_username=#{@options[:ro_username]}\n"\
                "ro_password=#{@options[:ro_password]}\n"
      end
    end
  end
end

