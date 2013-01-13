class Yggdrasil

  # @param [Array] args
  def diff(args)
    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password, '-r'=>:revision, '--revision'=>:revision})
    options = input_user_pass(options)

    sync_mirror options

    paths = Array.new
    if args.size == 0
      paths.push @current_dir.sub(%r{^/}, '')
    else
      args.each do |path|
        path = "#@current_dir/#{path}" unless %r{^/} =~ path
        paths.push path.sub(%r{^/}, '')
      end
    end

    cmd_arg = "#@svn diff --no-auth-cache --non-interactive"
    cmd_arg += " --username #{options[:username]} --password #{options[:password]}"
    cmd_arg += " -r #{options[:revision]}" if options.has_key?(:revision)
    cmd_arg += ' '+paths.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)
    end
  end
end
