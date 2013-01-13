class Yggdrasil

  # @param [Array] args
  def list(args)
    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-r'=>:revision, '--revision'=>:revision,
         '-R'=>:recursive?, '--recursive'=>:recursive?,
         '--depth'=>:depth})
    options = input_user_pass(options)

    sync_mirror options

    repos = Array.new
    if args.size == 0
      repos.push @repo+@current_dir
    else
      args.each do |path|
        path = "#@current_dir/#{path}" unless %r{^/} =~ path
        repos.push @repo+path
      end
    end

    cmd_arg = "#@svn list --no-auth-cache --non-interactive"
    cmd_arg += " --username #{options[:username]} --password #{options[:password]}"
    cmd_arg += " -r #{options[:revision]}" if options.has_key?(:revision)
    cmd_arg += " -R" if options.has_key?(:recursive?)
    cmd_arg += " --depth #{options[:depth]}" if options.has_key?(:depth)
    cmd_arg += ' ' + repos.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)
    end
  end
end
