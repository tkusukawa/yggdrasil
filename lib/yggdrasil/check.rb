require 'find'
require 'stringio'

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
    if File.exist?(@checker_dir)
      Find.find(@checker_dir) do |file|
        if File.file?(file) && File.executable?(file)
          if file =~ %r{^#@checker_dir(.*)$}
            file_body = $1
            system3("#{file} > #@checker_result_dir#{file_body}")
          end
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
    check_result = String.new
    FileUtils.cd @mirror_dir do
      check_result = system3(cmd_arg)
    end
    check_result.gsub!(/^Status against revision:.*\n/, '')
    check_result.chomp!
    if check_result == ''
      puts 'yggdrasil check: OK!'
    else
      check_result << "\n\n"
      cmd_arg = "#@svn diff --no-auth-cache --non-interactive -r HEAD"
      cmd_arg += username_password_options_to_read_repo
      FileUtils.cd @mirror_dir do
        check_result << system3(cmd_arg)
      end
      puts check_result
    end

    if /^(.+):(\d+)$/ =~ @options[:server]
      host = $1
      port = $2
      # put check_result to server
      sock = TCPSocket.open(host, port)
      error "can not connect to server: #{host}:#{port}" if sock.nil?
      sock.puts "put_result #{Socket.gethostname}"
      sock.puts check_result
      sock.close
    end
  end
end
