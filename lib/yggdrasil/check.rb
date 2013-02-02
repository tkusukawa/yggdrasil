require 'find'

class Yggdrasil

  def check(args)
    args = parse_options(args,
                         {'--username'=>:username, '--password'=>:password,
                          '--non-interactive'=>:non_interactive?})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    # execute checker
    `rm -rf #@checker_result_dir`
    Dir.mkdir @checker_result_dir, 0755
    Find.find(@checker_dir).each do |file|
      if File.file?(file) && File.executable?(file)
        if file =~ %r{^#@checker_dir(.*)$}
          file_body = $1
          system3("#{file} > #@checker_result_dir#{file_body}")
        end
      end
    end

    # add checker result
    result_files = Array.new
    Find.find(@checker_result_dir) {|f| result_files << f}
    stdout = $stdout
    $stdout = StringIO.new
    add result_files
    $stdout = stdout

    get_user_pass_if_need_to_read_repo
    sync_mirror

    cmd_arg = "#@svn status -qu --no-auth-cache --non-interactive"
    cmd_arg += username_password_options_to_read_repo
    FileUtils.cd @mirror_dir do
      out = system3(cmd_arg)
      puts out.gsub(/^Status against revision:.*\n/, '')
    end
    puts

    cmd_arg = "#@svn diff --no-auth-cache --non-interactive -r HEAD"
    cmd_arg += username_password_options_to_read_repo
    FileUtils.cd @mirror_dir do
      out = system3(cmd_arg)
      puts out
    end
  end
end
