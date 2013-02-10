class Yggdrasil

  # @param [Array] args
  def log(args)
    args = parse_options(args,
                         {'--username'=>:username, '--password'=>:password,
                          '-r'=>:revision, '--revision'=>:revision})
    get_user_pass_if_need_to_read_repo

    if args.size == 0
      dir = @mirror_dir + @current_dir
      error 'current directory is not managed.' unless File.exist?(dir)
      args << dir
    else
      args.collect! do |arg|
        if %r{^/} =~ arg
          @mirror_dir + arg
        else
          @mirror_dir + @current_dir + '/' + arg
        end
      end
    end

    cmd_arg = "#@svn log --no-auth-cache --non-interactive"
    cmd_arg += username_password_options_to_read_repo
    if @options.has_key?(:revision)
      cmd_arg += " -r #{@options[:revision]}"
    else
      cmd_arg += ' -r HEAD:1'
    end
    cmd_arg += ' ' + args.join(' ')
    puts system3(cmd_arg)
  end
end
