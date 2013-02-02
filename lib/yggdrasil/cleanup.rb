class Yggdrasil

  # @param [Array] args
  def cleanup(args)
    args = parse_options(args, {'--username'=>:username, '--password'=>:password})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    get_user_pass_if_need_to_read_repo

    system3 "rm -rf #@mirror_dir"

    cmd = "#@svn checkout --no-auth-cache --non-interactive #@repo #@mirror_dir"
    cmd += username_password_options_to_read_repo
    system3 cmd
  end
end
