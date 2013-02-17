require 'find'
require 'stringio'

class Yggdrasil

  def check(args)
    parse_options(args,
                  {'--username'=>:username, '--password'=>:password,
                   '--non-interactive'=>:non_interactive?})
    @arg_paths << '/' if @arg_paths.size == 0
    get_user_pass_if_need_to_read_repo

    exec_checker

    updates = sync_mirror
    matched_updates = select_updates(updates, @arg_paths)
    if matched_updates.size == 0
      puts 'no files.'
      return
    end

    confirmed_updates = confirm_updates(matched_updates) do |relative_path|
      FileUtils.cd @mirror_dir do
        cmd = "#@svn diff --no-auth-cache --non-interactive #{relative_path}"
        cmd += username_password_options_to_read_repo
        puts system3(cmd)
      end
    end
    return unless confirmed_updates
    return if confirmed_updates.size == 0

    check_result = String.new
    FileUtils.cd @mirror_dir do
      cmd = "#@svn status -quN --no-auth-cache --non-interactive"
      cmd += username_password_options_to_read_repo
      cmd += " #{confirmed_updates.join(' ')}"
      check_result = system3(cmd)
    end
    check_result.gsub!(/^Status against revision:.*\n/, '')
    check_result.chomp!
    result_array = check_result.split("\n")
    result_array.sort!.uniq!
    check_result = result_array.join("\n")

    if check_result == ''
      puts 'yggdrasil check: OK!'
    else
      check_result << "\n\n"
      cmd = "#@svn diff --no-auth-cache --non-interactive"
      cmd += username_password_options_to_read_repo
      cmd += " #{confirmed_updates.join(' ')}"
      FileUtils.cd @mirror_dir do
        check_result << system3(cmd)
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
