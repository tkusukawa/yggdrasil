class Yggdrasil

  # @param [Array] args
  def commit(args)
    target_paths, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-m'=>:message, '--message'=>:message, '--non-interactive'=>:non_interactive?})
    options = input_user_pass(options)

    updates = sync_mirror(options)
    matched_updates = select_updates(updates, target_paths)
    if matched_updates.size == 0
      puts "\nno files."
      return
    end

    confirmed_updates = confirm_updates(matched_updates,options) do |relative_path|
      FileUtils.cd @mirror_dir do
        puts system3("#@svn diff --no-auth-cache --non-interactive #{relative_path}")
      end
    end
    return unless confirmed_updates
    return if confirmed_updates.size == 0

    until options.has_key?(:message) do
      print "Input log message: "
      input = $stdin.gets
      options[:message] = input.chomp
    end

    FileUtils.cd @mirror_dir do
      puts system3 "#@svn commit -m '#{options[:message]}'"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{options[:username]}' --password '#{options[:password]}'"\
                   " #{confirmed_updates.join(' ')}"
    end
  end
end
