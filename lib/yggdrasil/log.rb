class Yggdrasil

  # @param [Array] args
  def log(args)
    args, options = parse_options(args,
                                  {'--username'=>:username, '--password'=>:password,
                                   '-r'=>:revision, '--revision'=>:revision})
    options = input_user_pass(options)

    if args.size == 0
      dir = @mirror_dir+@work_dir
      error "current directory is not managed." unless File.exist?(dir)
      args.push dir
    else
    args.collect! do |arg|
      if %r{^/} =~ arg
        @mirror_dir+arg
      else
        @mirror_dir+@work_dir+'/'+arg
      end
    end
    end

    cmd_arg = "#@svn log --verbose"
    if options.has_key?(:revision)
      cmd_arg += " -r #{options[:revision]}"
    else
      cmd_arg += " -r HEAD:1"
    end
    cmd_arg += ' ' + args.join(' ')
    puts system3(cmd_arg)
  end
end
