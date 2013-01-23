class Yggdrasil

  # @param [Array] args
  def cleanup(args)
    args = parse_options(args, {'--username'=>:username, '--password'=>:password})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    input_user_pass unless @anon_access

    system3 "rm -rf #@mirror_dir"

    cmd = "#@svn checkout --no-auth-cache --non-interactive #@repo #@mirror_dir"
    cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
    system3 cmd
  end
end
