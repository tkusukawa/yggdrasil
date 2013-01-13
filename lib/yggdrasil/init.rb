class Yggdrasil

  # @param [Array] args
  def Yggdrasil.init(args)
    ENV['LANG'] = 'en_US.UTF-8'

    args, options = parse_options(args,
        {'--repo'=>:repo, '--username'=>:username, '--password'=>:password})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    out = system3 'which svn'
    svn = out.chomp

    out = system3 'svn --version'
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

    until options.has_key?(:repo) do
      print "Input svn repo URL: "
      input = $stdin.gets

      unless /^(http:|file:|svn:)/ =~ input
        puts "ERROR: Invalid URL."
        redo
      end
      options[:repo] = input
    end
    options[:repo].chomp!
    options[:repo].chomp!('/')

    options = input_user_pass(options)

    puts "SVN access test..."
    loop do
      ret = system3 "#{svn} ls --no-auth-cache --non-interactive"\
                         " --username '#{options[:username]}' --password '#{options[:password]}'"\
                         " #{options[:repo]}", false
      unless ret.nil?
        puts "SVN access: OK."
        break
      end

      ret = system3 "#{svn} mkdir --parents -m 'yggdrasil init'"\
                         " --no-auth-cache --non-interactive"\
                         " --username '#{options[:username]}' --password '#{options[:password]}'"\
                         " #{options[:repo]}", false
      unless ret.nil?
        puts "SVN mkdir: OK."
        break
      end

      puts "SVN error: can not access to '#{options[:repo]}'."
      exit 1
    end

    Dir.mkdir config_dir, 0755
    File.write config_dir+'/config',
               "path=#{ENV['PATH']}\n"\
               "svn=#{svn}\n"\
               "svn_version=#{svn_version}\n"\
               "repo=#{options[:repo]}\n"

    ret = system3 "#{svn} checkout"\
                       " --no-auth-cache --non-interactive"\
                       " --username '#{options[:username]}' --password '#{options[:password]}'"\
                       " #{options[:repo]} #{config_dir+'/mirror'}", false
    if ret.nil?
      puts "SVN checkout: error."
      exit 1
    end
  end
end
