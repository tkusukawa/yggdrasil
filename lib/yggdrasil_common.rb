module YggdrasilCommon

=begin
  def method_missing(action, *args)
    self.class.send action, *args
  end
=end

  # load config value from config file
  def read_config(config_file)
    configs = Hash.new
    begin
      File.open(config_file) do |file|
        l = 0
        while (line = file.gets)
          l += 1
          next if /^\s*#.*$/ =~ line  # comment line
          if /^\s*(\S+)\s*=\s*(\S+).*$/ =~ line
            key, val = $1, $2
            key.gsub!(/-/, '_')
            configs[key.to_sym] = val
          else
            error "syntax error. :#{config_file}(#{l})"
          end
        end
      end
    rescue
      error "can not open config file: #{config_file}"
    end
    configs
  end

  def parse_options(args, valid_params)
    valid_params['--debug'] = :debug? # common
    @options ||= Hash.new
    pos = 0
    while args.size > pos
      if valid_params.has_key?(args[pos])
        option_note = args[pos]
        option_key = valid_params[option_note]
        args = args[0...pos]+args[pos+1..-1]
        if option_key.to_s[-1,1] == '?'
          @options[option_key] = true
        else
          error "Not enough arguments provided: #{option_note}" unless args.size > pos
          option_value = args[pos].dup
          args = args[0...pos]+args[pos+1..-1]
          @options[option_key] = option_value
        end
        next
      end
      pos += 1
    end
    args
  end

  def input_user_pass
    until @options.has_key?(:username) do
      error 'Can\'t get username or password' if @options.has_key?(:non_interactive?)
      print 'Input svn username: '
      input = $stdin.gets
      error 'can not input username' unless input
      input.chomp!
      return if input.size == 0
      @options[:username] = @options[:ro_username] = input
    end
    until @options.has_key?(:password) do
      error 'Can\'t get username or password' if @options.has_key?(:non_interactive?)
      print 'Input svn password: '
      #input = `sh -c 'read -s hoge;echo $hoge'`
      system3 'stty -echo', false
      input = $stdin.gets
      system3 'stty echo', false
      puts
      error 'can not input password' unless input
      input.chomp!
      @options[:password] = @options[:ro_password] = input
    end
  end

  # @param [String] cmd
  def system3(cmd, err_exit=true)
    out = `#{cmd} 2>&1`
    stat = $?

    unless stat.success?
      return nil unless err_exit
      $stderr.puts "#@base_cmd error: command failure: #{cmd}"
      $stderr.puts 'command output:'
      $stderr.puts out
      exit stat.exitstatus
    end
    out
  end

  # @param [String] msg
  def error(msg)
    $stderr.puts "#@base_cmd error: #{msg}"
    $stderr.puts
    exit 1
  end
end
