class Yggdrasil

  # @param [Array] args
  def commit(args)
    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-m'=>:message, '--message'=>:message, '--non-interactive'=>:non_interactive?})
    options = input_user_pass(options)

    target_files = select_targets(options, args)
    return unless target_files

    until options.has_key?(:message) do
      print "Input log message: "
      input = $stdin.gets
      options[:message] = input.chomp
    end

    FileUtils.cd @mirror_dir do
      system3 "#@svn commit -m '#{options[:message]}'"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{options[:username]}' --password '#{options[:password]}'"\
                   " #{target_files.join(' ')}"
    end
  end
end
