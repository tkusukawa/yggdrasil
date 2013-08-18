class Yggdrasil

  # @param [Array] args
  def cleanup(args)
    parse_options(args, {'--username'=>:username, '--password'=>:password})
    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    get_user_pass_if_need_to_read_repo

    system3 "rm -rf #{@mirror_dir}"

    cmd = "#{@svn} checkout --no-auth-cache --non-interactive #{@repo} #{@mirror_dir}"
    cmd += username_password_options_to_read_repo
    system3 cmd
  end
end
