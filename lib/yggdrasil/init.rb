class Yggdrasil

  # @param [Array] args
  def Yggdrasil.init(args)

    ENV['LANG'] = 'en_US.UTF-8'

    arg_hash=Hash.new
    while args.size!=0 do
      option=args.shift
      case option
        when '--repo'
          command_error "Not enough arguments provided: #{option}" if args.empty?
          arg_hash[:repo]=args.shift
        when '--username'
          command_error "Not enough arguments provided: #{option}" if args.empty?
          arg_hash[:username]=args.shift
        when '--password'
          command_error "Not enough arguments provided: #{option}" if args.empty?
          arg_hash[:password]=args.shift
        else
          command_error "invalid option: #{option}"
      end
    end

    out = exec_command 'which svn'
    svn_path = out.chomp

    out = exec_command 'svn --version'
    unless /version (\d+\.\d+\.\d+) / =~ out
      puts "#{CMD} error: can not find version string: svn --version"
      exit 1
    end
    svn_version=$1

    config_dir =  ENV["HOME"] + '/.yggdrasil'
    if File.exist?(config_dir)
      puts "#{CMD} error: already exist .yggdrasil directory: #{config_dir}"
      exit 1
    end

    until arg_hash.has_key?(:repo) do
      print "Input svn repo URL:"
      input = $stdin.gets

      unless /^(http:|file:|svn:)/ =~ input
        puts "ERROR: Invalid URL."
        redo
      end
      arg_hash[:repo] = input
    end
    arg_hash[:repo].chomp!
    arg_hash[:repo].chomp!('/')

    until arg_hash.has_key?(:username) do
      print "Input svn username:"
      input = $stdin.gets
      arg_hash[:username] = input.chomp
    end
    until arg_hash.has_key?(:password) do
      print "Input svn password:"
      input = $stdin.gets
      arg_hash[:password] = input.chomp
    end

    puts "SVN access test..."
    loop do
      ret = Open3.capture2e "#{svn_path} ls --no-auth-cache --non-interactive"\
                          " --username '#{arg_hash[:username]}' --password '#{arg_hash[:password]}'"\
                          " #{arg_hash[:repo]}"
      if ret[1].success?
        puts "SVN access: OK."
        break
      end

      ret = Open3.capture2e "#{svn_path} mkdir --parents -m 'yggdrasil init'"\
                          " --no-auth-cache --non-interactive"\
                          " --username '#{arg_hash[:username]}' --password '#{arg_hash[:password]}'"\
                          " #{arg_hash[:repo]}"
      if ret[1].success?
        puts "SVN mkdir: OK."
        break
      end

      puts "SVN error: can not access to '#{arg_hash[:repo]}'."
      exit 1
    end

    Dir.mkdir config_dir, 0755
    File.write config_dir+'/config',
               "path=#{ENV['PATH']}\n"\
               "svn=#{svn_path}\n"\
               "svn_version=#{svn_version}\n"\
               "repo=#{arg_hash[:repo]}\n"

    ret = Open3.capture2e "#{svn_path} checkout"\
                        " --no-auth-cache --non-interactive"\
                        " --username '#{arg_hash[:username]}' --password '#{arg_hash[:password]}'"\
                        " #{arg_hash[:repo]} #{config_dir+'/mirror'}"
    unless ret[1].success?
      puts "SVN checkout: error."
      exit 1
    end
  end
end
