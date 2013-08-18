class Yggdrasil

  # @param [Array] args
  def list(args)
    parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-r'=>:revision, '--revision'=>:revision,
         '-R'=>:recursive?, '--recursive'=>:recursive?})
    if @arg_paths.size == 0
      @arg_paths << '/'
      @options[:recursive?] = true
    end
    get_user_pass_if_need_to_read_repo

    repos = Array.new
    @arg_paths.each do |path|
      path = "#{@current_dir}/#{path}" unless %r{^/} =~ path
      repos << @repo+path
    end

    cmd_arg = "#{@svn} list --no-auth-cache --non-interactive"
    cmd_arg += username_password_options_to_read_repo
    cmd_arg += " -r #{@options[:revision]}" if @options.has_key?(:revision)
    cmd_arg += ' -R' if @options.has_key?(:recursive?)
    cmd_arg += ' ' + repos.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)
    end
  end
end
