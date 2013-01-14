class Yggdrasil

  # @param [Array] args
  def update(args)
    args, options = parse_options(args,
                                  {'--username'=>:username, '--password'=>:password,
                                   '-r'=>:revision, '--revision'=>:revision,
                                   '--non-interactive'=>:non_interactive?})
    options = input_user_pass(options)
    sync_mirror options

    updates = Array.new
    FileUtils.cd @mirror_dir do
      out = system3("#@svn status -qu --depth infinity --no-auth-cache --non-interactive" +
                      " --username '#{options[:username]}' --password '#{options[:password]}'")
      out.split(/\n/).each do |line|
        updates << $1 if /^.*\*.*\s(\S+)\s*$/ =~ line
      end
    end

    if  args.size == 0
      args << @current_dir.sub(%r{^/},'')
    else
      args.collect! do |arg|
        if %r{^/(.*)$} =~ arg
          $1
        else
          @current_dir.sub(%r{^/},'') + '/' + arg
        end
      end
    end

    # search updated files in the specified dir
    cond = '^'+args.join('|^') # make reg exp
    matched_updates = Array.new
    updates.each do |update|
      matched_updates << update if update.match(cond)
    end

    # search parent dir of commit files
    parents = Array.new
    updates.each do |update|
      matched_updates.each do |matched_update|
        parents << update if matched_update.match("^#{update}/")
      end
    end
    matched_updates += parents
    matched_updates.sort!
    matched_updates.uniq!

    return nil if matched_updates.size == 0 # no files to commit

    until options.has_key?(:non_interactive?)
      puts
      (0...matched_updates.size).each do |i|
        puts "#{i}:#{matched_updates[i]}"
      end
      puts "OK? [Y|n|<num to diff>]:"
      res = $stdin.gets
      return unless res
      res.chomp!
      break if res == 'Y'
      return nil if res == 'n'
      next unless matched_updates[res.to_i]
      if /^\d+$/ =~ res
        FileUtils.cd @mirror_dir do
          relative = matched_updates[res.to_i].sub(%r{^/},'')
          cmd = "#@svn diff"
          cmd += " --no-auth-cache --non-interactive"
          cmd += " --username #{options[:username]} --password #{options[:password]}"
          if options.has_key?(:revision)
            cmd += " --old=#{relative} --new=#{relative}@#{options[:revision]}"
          else
            cmd += " --old=#{relative} --new=#{relative}@HEAD"
          end
          puts system3(cmd)
        end
      end
    end

    # res == 'Y' or --non-interactive

    cmd_arg = "#@svn update --no-auth-cache --non-interactive"
    cmd_arg += " --username #{options[:username]} --password #{options[:password]}"
    if options.has_key?(:revision)
      cmd_arg += " -r #{options[:revision]}"
    else
      cmd_arg += " -r HEAD"
    end
    cmd_arg += ' ' + matched_updates.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)

      # reflect mirror to real file
      matched_updates.each do |matched_update|
        if File.exist?(matched_update)
          FileUtils.copy_file @mirror_dir+'/'+matched_update, '/'+matched_update
        else
          system3 "rm -rf /#{matched_update}"
        end
      end
    end
  end
end
