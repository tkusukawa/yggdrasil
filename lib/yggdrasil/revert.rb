class Yggdrasil

  # @param [Array] args
  def revert(args)
    args, options = parse_options(args,
                                  {'--username'=>:username, '--password'=>:password,
                                   '--non-interactive'=>:non_interactive?})
    options = input_user_pass(options)

    target_files = select_targets(options, args)
    return unless target_files

    FileUtils.cd @mirror_dir do
      system3 "#@svn revert"\
                   " --no-auth-cache --non-interactive"\
                   " --username '#{options[:username]}' --password '#{options[:password]}'"\
                   " #{target_files.reverse.join(' ')}"

      # make ls hash
      out = system3("#@svn ls --no-auth-cache --non-interactive"\
                           " --username '#{options[:username]}' --password '#{options[:password]}'"\
                           " --depth infinity #@repo")
      ls_hash = Hash.new
      out.split(/\n/).each {|relative| ls_hash[relative]=true}

      # reflect mirror to real file
      target_files.each do |target_file|
        if ls_hash.has_key?(target_file)
          FileUtils.copy_file @mirror_dir+'/'+target_file, '/'+target_file
        else
          system3 "rm -rf @mirror_dir+'/'+target_file"
        end
      end
    end
  end
end
