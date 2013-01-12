class Yggdrasil

  # @param [Array] args
  def cleanup(args)
    args, options = parse_options(args, {'--username'=>:username, '--password'=>:password})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    options = input_user_pass(options)

    exec_command "rm -rf #@mirror_dir"

    exec_command "#@svn checkout"\
                 " --no-auth-cache --non-interactive"\
                 " --username '#{options[:username]}' --password '#{options[:password]}'"\
                 " #@repo #@mirror_dir"
  end
end
