class Yggdrasil

  # @param [Array] args
  def commit(args)
    target_paths = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-m'=>:message, '--message'=>:message, '--non-interactive'=>:non_interactive?})
    input_user_pass unless @anon_access

    updates = sync_mirror
    matched_updates = select_updates(updates, target_paths)
    if matched_updates.size == 0
      puts "\nno files."
      return
    end

    confirmed_updates = confirm_updates(matched_updates) do |relative_path|
      FileUtils.cd @mirror_dir do
        puts system3("#@svn diff --no-auth-cache --non-interactive #{relative_path}")
      end
    end
    return unless confirmed_updates
    return if confirmed_updates.size == 0

    message = ''
    print "Input log message: "
    until @options.has_key?(:message) do
      input = $stdin.gets
      if  input && input.chomp!
        if input =~ /^(.*)\\$/
          message += $1+"\n"
          next
        else
          message += input
        end
      else
        error "can not input log message"
      end
      @options[:message] = message
    end

    input_user_pass
    FileUtils.cd @mirror_dir do
      puts system3 "#@svn commit -m '#{@options[:message]}'"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{@options[:username]}' --password '#{@options[:password]}'"\
                   " #{confirmed_updates.join(' ')}"
    end
  end
end
