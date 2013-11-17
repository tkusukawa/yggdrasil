require 'find'
require 'stringio'

class Yggdrasil

  def check(args)
    parse_options(args,
                  {'--username'=>:username, '--password'=>:password,
                   '--non-interactive'=>:non_interactive?})
    error "invalid options: #{(@arg_options).join(', ')}" if @arg_options.size != 0

    @arg_paths << '/' if @arg_paths.size == 0
    get_user_pass_if_need_to_read_repo

    exec_checker

    matched_updates = sync_mirror(@arg_paths)

    check_result = String.new
    if matched_updates.size != 0
      confirmed_updates = confirm_updates(matched_updates, %w{A q}) do |relative_path|
        FileUtils.cd @mirror_dir do
          cmd = "#{@svn} diff --no-auth-cache --non-interactive #{relative_path}"
          cmd += username_password_options_to_read_repo
          puts system3(cmd)
        end
      end
      return unless confirmed_updates
      return if confirmed_updates.size == 0

      ##############  add status information to check_result
      FileUtils.cd @mirror_dir do
        cmd = "#{@svn} status -quN --no-auth-cache --non-interactive"
        cmd += username_password_options_to_read_repo
        cmd += " #{confirmed_updates.join(' ')}"
        check_result = system3(cmd)
      end
      check_result.gsub!(/^Status against revision:.*\n/, '')
      check_result.chomp!
      result_array = check_result.split("\n")
      result_array.sort!.uniq!
      check_result = result_array.join("\n")
      check_result << "\n\n"

      ##############  add diff information to check_result
      FileUtils.cd @mirror_dir do
        result_array.each do |result_line|
          if result_line =~ /\s(\S+)$/
            result_path = $1
            next if File.directory?(result_path)
            cmd = "#{@svn} diff --no-auth-cache --non-interactive"
            cmd += username_password_options_to_read_repo
            cmd += ' '+result_path
            check_result << system3(cmd) +"\n"
          end
        end
      end
    end

    if @arg_paths.size == 1 && @arg_paths[0] == '/'
      if /^(.+):(\d+)$/ =~ @options[:server]
        host = $1
        port = $2
        error 'no hostname in config' unless @options.has_key?(:hostname)

        hostname = @options[:hostname]
        # put check_result to server
        sock = TCPSocket.open(host, port)
        error "can not connect to server: #{host}:#{port}" if sock.nil?
        sock.puts "put_result #{hostname}"
        sock.puts check_result
        sock.close
      end
    end

    puts @target_file_num.to_s + ' files checked.'
    return if @target_file_num == 0
    if check_result == ''
      puts 'Yggdrasil check: OK.'
    else
      puts check_result
      puts 'Yggdrasil check: NG!!!'
    end
  end
end
