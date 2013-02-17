class Yggdrasil

  # @param [Array] args
  def log(args)
    parse_options(args,
                         {'--username'=>:username, '--password'=>:password,
                          '-r'=>:revision, '--revision'=>:revision})
    @arg_paths << '/' if @arg_paths.size == 0

    get_user_pass_if_need_to_read_repo

    paths = Array.new
    err_paths = Array.new
    @arg_paths.each do |path|
      if %r{^/(.*)$} =~ path
        mirror_file = $1
        mirror_file = '.' if mirror_file == ''
      else
        mirror_file = @current_dir.sub(/^\//,'') + '/' + path
      end
      if File.exist?(@mirror_dir+'/'+mirror_file)
        paths << mirror_file
      else
        err_paths << mirror_file
      end
    end
    if err_paths.size != 0
      error "following files are not managed.\n"+err_paths.join("\n")
    end

    cmd_arg = "#@svn log --no-auth-cache --non-interactive"
    cmd_arg += username_password_options_to_read_repo
    cmd_arg += ' ' + @arg_options.join(' ') if @arg_options.size != 0
    if @options.has_key?(:revision)
      cmd_arg += " -r #{@options[:revision]}"
    else
      cmd_arg += ' -r HEAD:1'
    end
    cmd_arg += ' ' + paths.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)
    end
  end
end
