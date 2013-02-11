class Yggdrasil

  # @param [Array] args
  def log(args)
    args = parse_options(args,
                         {'--username'=>:username, '--password'=>:password,
                          '-r'=>:revision, '--revision'=>:revision})
    get_user_pass_if_need_to_read_repo

    ext_options = Array.new
    paths = Array.new
    args.each do |arg|
      if /^-/ =~ arg
        ext_options << arg
      else
        paths << arg
      end
    end

    if paths.size == 0
      dir = @mirror_dir + @current_dir
      error 'current directory is not managed.' unless File.exist?(dir)
      paths << dir
    else
      paths.collect! do |path|
        if %r{^/} =~ path
          @mirror_dir + path
        else
          @mirror_dir + @current_dir + '/' + path
        end
      end
    end

    cmd_arg = "#@svn log --no-auth-cache --non-interactive"
    cmd_arg += username_password_options_to_read_repo
    cmd_arg += ' ' + ext_options.join(' ') if ext_options.size != 0
    if @options.has_key?(:revision)
      cmd_arg += " -r #{@options[:revision]}"
    else
      cmd_arg += ' -r HEAD:1'
    end
    cmd_arg += ' ' + paths.join(' ')
    puts system3(cmd_arg)
  end
end
