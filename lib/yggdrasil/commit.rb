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
    until options.has_key?(:message) do
      print "Input log message: "
      input = $stdin.gets
      options[:message] = input.chomp
    end

    FileUtils.cd @mirror_dir
    if args.size == 0
      out = Yggdrasil.exec_command("#{@svn} ls --depth infinity #{@repo}")
      puts "\n""exec: svn ls\n#{out}"
      files = out.split(/\n/)
      out = Yggdrasil.exec_command("#{@svn} status -q")
      puts "\n""exec: svn status\n#{out}"
      out.split(/\n/).each do |line|
        if /^.*\s(\S+)\s*$/ =~ line
          files.push($1)
        end
      end

      files.sort!
      files.uniq!
    else
      files = args
    end

    files.each do |file|
      puts file
    end
  end
end
