class Yggdrasil

  # @param [Array] args
  def diff(args)
    args, options = parse_options(args, {'--username'=>:username, '--password'=>:password, '-r'=>:revision})
    options = input_user_pass(options)

    sync_mirror options

    paths = Array.new
    args.each do |path|
      path = "#@work_dir/#{path}" unless %r{^/} =~ path
      paths.push path.sub(%r{^/}, '')
    end

    cmd_arg = "#@svn diff "
    cmd_arg += "-r #{options[:revision]} " if options.has_key?(:revision)
    cmd_arg += paths.join(' ')
    FileUtils.cd @mirror_dir do
      puts exec_command(cmd_arg)
    end
  end
end
