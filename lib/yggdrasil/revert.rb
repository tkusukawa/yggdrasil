class Yggdrasil

  # @param [Array] args
  def revert(args)
    target_paths, options = parse_options(args,
                                  {'--username'=>:username, '--password'=>:password,
                                   '--non-interactive'=>:non_interactive?})
    options = input_user_pass(options)

    updates = sync_mirror(options)
    matched_updates = select_updates(updates, target_paths)
    if matched_updates.size == 0
      puts "\nno files."
      return
    end

    confirmed_updates = confirm_updates(matched_updates,options) do |relative_path|
      FileUtils.cd @mirror_dir do
        puts system3("#@svn diff --no-auth-cache --non-interactive #{relative_path}")
      end
    end

    return unless confirmed_updates
    return if confirmed_updates.size == 0

    FileUtils.cd @mirror_dir do
      system3 "#@svn revert"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{options[:username]}' --password '#{options[:password]}'"\
                   " #{confirmed_updates.reverse.join(' ')}"

      # make ls hash
      out = system3("#@svn ls --no-auth-cache --non-interactive"\
                           " --username '#{options[:username]}' --password '#{options[:password]}'"\
                           " --depth infinity #@repo")
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
