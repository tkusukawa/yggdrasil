class Yggdrasil

  # @param [Array] args
  def update(args)
    target_paths, options = parse_options(args,
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

    matched_updates = select_updates(updates, target_paths)

    confirmed_updates = confirm_updates(matched_updates,options) do |relative_path|
      FileUtils.cd @mirror_dir do
        cmd = "#@svn diff"
        cmd += " --no-auth-cache --non-interactive"
        cmd += " --username #{options[:username]} --password #{options[:password]}"
        if options.has_key?(:revision)
          cmd += " --old=#{relative_path} --new=#{relative_path}@#{options[:revision]}"
        else
          cmd += " --old=#{relative_path} --new=#{relative_path}@HEAD"
        end
        puts system3(cmd)
      end
    end
    # res == 'Y' or --non-interactive

    return unless confirmed_updates
    return if confirmed_updates == 0 # no files to update

    cmd_arg = "#@svn update --no-auth-cache --non-interactive"
    cmd_arg += " --username #{options[:username]} --password #{options[:password]}"
    if options.has_key?(:revision)
      cmd_arg += " -r #{options[:revision]}"
    else
      cmd_arg += " -r HEAD"
    end
    cmd_arg += ' ' + confirmed_updates.join(' ')
    FileUtils.cd @mirror_dir do
      puts system3(cmd_arg)

      # reflect mirror to real file
      confirmed_updates.each do |update_file|
        if File.exist?(update_file)
          FileUtils.copy_file @mirror_dir+'/'+update_file, '/'+update_file
        else
          system3 "rm -rf /#{update_file}"
        end
      end
    end
  end
end
