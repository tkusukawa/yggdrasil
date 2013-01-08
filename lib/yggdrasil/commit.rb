class Yggdrasil

  # @param [Array] args
  def commit(args)
    args, options = Yggdrasil.parse_options(args,
        {'--username'=>:username, '--password'=>:password, '-m'=>:message, '--message'=>:message})

    until options.has_key?(:username) do
      print "Input svn username: "
      input = $stdin.gets
      options[:username] = input.chomp
    end
    until options.has_key?(:password) do
      print "Input svn password: "
      #input = `sh -c 'read -s hoge;echo $hoge'`
      `stty -echo`
      input = $stdin.gets
      `stty echo`
      puts
      options[:password] = input.chomp
    end

    current_dir = `readlink -f .`.chomp
    files = args
    if files.size == 0
      FileUtils.cd @mirror_dir do
        svn_cmd = "#{@svn} ls --username '#{options[:username]}' --password '#{options[:password]}'"\
                  " --depth infinity #{@repo}"
        out = Yggdrasil.exec_command(svn_cmd)
        puts "\n" "exec: svn ls\n#{out}"
        files = out.split(/\n/)
        svn_cmd = "#{@svn} status --username '#{options[:username]}' --password '#{options[:password]}' -q"
        out = Yggdrasil.exec_command(svn_cmd)
        puts "\n" "exec: svn status\n#{out}"
        out.split(/\n/).each do |line|
          if /^.*\s(\S+)\s*$/ =~ line
            files.push($1)
          end
        end
      end
      current_dir = ''
    end

    files.collect! do |file|
      if %r{^/} =~ file
        file
      else
        "#{current_dir.chomp('/')}/#{file}"
      end
    end
    files.sort!
    files.uniq!

    FileUtils.cd @mirror_dir do
      files.each do |file|
        unless File.exist?(file)
          Yggdrasil.exec_command "#{@svn} delete #{file.sub(%r{^/},'')}"
          next
        end
        if File.file?(file)
          FileUtils.copy_file file, @mirror_dir+file
          Yggdrasil.exec_command "#{@svn} status #{file.sub(%r{^/},'')}"
        end
      end
    end

    puts "Do you want to commit above? [Yn]:"
    if $stdin.gets.chomp == 'Y'
      until options.has_key?(:message) do
        print "Input log message: "
        input = $stdin.gets
        options[:message] = input.chomp
      end
      file_list = ''
      files.each do |file|
        file_list += ' '+file.sub(%r{^/}, '' )
      end
      svn_cmd = "#{@svn} commit -m '#{options[:message]}'"\
                " --username '#{options[:username]}' --password '#{options[:password]}'"\
                " #{file_list}"
      FileUtils.cd @mirror_dir do
        Yggdrasil.exec_command(svn_cmd)
      end
    end
  end
end
