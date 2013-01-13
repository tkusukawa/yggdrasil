class Yggdrasil

  # @param [Array] args
  def commit(args)
    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '-m'=>:message, '--message'=>:message, '--non-interactive'=>:non_interactive?})

    options = input_user_pass(options)

    files = sync_mirror(options)
    files = args if args.size!=0

    file_num = 0
    num_file = Array.new
    FileUtils.cd @mirror_dir do
      files.each do |file|
        file = @work_dir+'/'+file unless %r{^/} =~ file
        relative = file.sub(%r{^/}, '')
        next if File.exist?(file) && !File.file?(file)
        out = system3("#@svn status --no-auth-cache --non-interactive #{relative}").chomp!
        if out && out != ""
          num_file[file_num] = {:relative=>relative, :status=>out}
          file_num += 1
        end
      end
    end

    until options.has_key?(:non_interactive?)
      (0...num_file.size).each do |i|
        puts "#{i}:#{num_file[i][:status]}"
      end
      puts "Do you want to commit above? [Yn|<num to diff>]:"
      res = $stdin.gets
      return unless res
      res.chomp!
      break if res == 'Y'
      return if res == 'n'
      if /^\d+$/ =~ res
        FileUtils.cd @mirror_dir do
          puts system3("#@svn diff --no-auth-cache --non-interactive #{num_file[res.to_i][:relative]}")
        end
      end
    end

    # if res == 'Y'
    until options.has_key?(:message) do
      print "Input log message: "
      input = $stdin.gets
      options[:message] = input.chomp
    end
    file_list = ''
    files.each do |file|
      file_list += ' '+file.sub(%r{^/}, '')
    end

    FileUtils.cd @mirror_dir do
      system3 "#@svn commit -m '#{options[:message]}'"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{options[:username]}' --password '#{options[:password]}'"\
                   " #{file_list}"
    end
  end
end
