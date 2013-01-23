class Yggdrasil

  # @param [Array] args
  def revert(args)
    target_paths = parse_options(args,
                                 {'--username'=>:username, '--password'=>:password,
                                  '--non-interactive'=>:non_interactive?})
    input_user_pass unless @anon_access

    updates = sync_mirror
    matched_updates = select_updates(updates, target_paths)
    if matched_updates.size == 0
      puts "\nno files."
      return
    end

    confirmed_updates = confirm_updates(matched_updates) do |relative_path|
      FileUtils.cd @mirror_dir do
        cmd = "#@svn diff --no-auth-cache --non-interactive #{relative_path}"
        cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
        puts system3(cmd)
      end
    end

    return unless confirmed_updates
    return if confirmed_updates.size == 0

    FileUtils.cd @mirror_dir do
      cmd = "#@svn revert #{confirmed_updates.reverse.join(' ')}"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
      system3 cmd

      # make ls hash
      cmd = "#@svn ls -R #@repo --no-auth-cache --non-interactive"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless @anon_access
      out = system3(cmd)

      ls_hash = Hash.new
      out.split(/\n/).each {|relative| ls_hash[relative]=true}

      # reflect mirror to real file
      confirmed_updates.each do |file|
        if ls_hash.has_key?(file)
          if File.file?("#@mirror_dir/#{file}")
            FileUtils.copy_file "#@mirror_dir/#{file}", "/#{file}"
          end
        else
          system3 "rm -rf #{@mirror_dir + '/' + file}"
        end
      end
    end
  end
end
