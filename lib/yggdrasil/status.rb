class Yggdrasil

  # @param [Array] args
  def status(args)
    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
        '--depth'=>:depth})
    options = input_user_pass(options)

    sync_mirror options

    paths = String.new
    if args.size == 0
      paths += ' '+@current_dir.sub(%r{^/}, '')
    else
      args.each do |path|
        path = "#@current_dir/#{path}" unless %r{^/} =~ path
        paths += ' ' + path.sub(%r{^/}, '')
      end
    end

    cmd_arg = "#@svn status#{paths} -qu --no-auth-cache --non-interactive"
    cmd_arg += " --username #{options[:username]} --password #{options[:password]}"
    cmd_arg += " --depth #{options[:depth]}" if options.has_key?(:depth)
    FileUtils.cd @mirror_dir do
      out = system3(cmd_arg)
      print out.gsub(/^Status against revision:.*\n/, '')
    end
  end
end
