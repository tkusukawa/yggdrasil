class Yggdrasil

  # @param [Array] args
  def commit(args)
    parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-m'=>:message, '--message'=>:message, '--non-interactive'=>:non_interactive?})
    @arg_paths << '/' if @arg_paths.size == 0
    get_user_pass_if_need_to_read_repo

    exec_checker

    matched_updates = sync_mirror(@arg_paths)
    if matched_updates.size == 0
      puts 'no files.'
      return
    end

    confirmed_updates = confirm_updates(matched_updates) do |relative_path|
      FileUtils.cd @mirror_dir do
        cmd = "#{@svn} diff --no-auth-cache --non-interactive #{relative_path}"
        cmd += username_password_options_to_read_repo
        puts system3(cmd)
      end
    end
    return unless confirmed_updates
    return if confirmed_updates.size == 0

    message = ''
    unless @options.has_key?(:message)
      print 'Input log message: '
      loop do
        input = $stdin.gets
        error 'can not input log message' unless input
        input.chomp!
        if input =~ /^(.*)\\$/
          message += $1+"\n"
        else
          message += input
          @options[:message] = message
          break
        end
      end
    end

    input_user_pass
    FileUtils.cd @mirror_dir do
      cmd = "#{@svn} commit -m \"#{@options[:message].gsub('"', '\"')}\""\
            ' --no-auth-cache --non-interactive'\
            " --username '#{@options[:username]}' --password '#{@options[:password]}'"\
            " #{confirmed_updates.join(' ')}"
      puts system3(cmd)
    end
  end
end
