class Yggdrasil

  # @param [Array] args
  def init(args)

    args, options = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '--repo'=>:repo, '--parents'=>:parents?, '--debug'=>:debug?})
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

    if File.exist?(@config_file)
      puts "#{CMD} error: already exist config file: #@config_file"
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
    url_parts = options[:repo].split('/')
    url_parts_num = url_parts.size
    loop do
      puts "url_parts_num=#{url_parts_num}" if options[:debug?]
      if url_parts_num < 3
        puts "SVN error: can not access to '#{options[:repo]}'."
        exit 1
      end
      url = url_parts[0...url_parts_num].join('/')
      puts "try url=#{url}" if options[:debug?]
      ret = system3("#{svn} ls --no-auth-cache --non-interactive" +
                        " --username '#{options[:username]}' --password '#{options[:password]}'" +
                        " #{url}", false)
      unless ret.nil?
        puts "SVN access OK: #{url}"
        break
      end

      url_parts_num -= 1
    end

    Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)

    if url_parts_num != url_parts.size
      until options[:parents?]
        puts "not exist directory(s): #{url_parts[url_parts_num...url_parts.size].join('/')}"
        print "make directory(s)? [Yn]: "
        input = $stdin.gets
        exit 1 if input.nil?
        input.chomp!
        return if input == 'n'
        break if input == 'Y'
      end
      `rm -rf #@mirror_dir`
      system3 "#{svn} checkout --no-auth-cache --non-interactive" +
                  " --username '#{options[:username]}' --password '#{options[:password]}'" +
                  " #{url_parts[0...url_parts_num].join('/')} #@mirror_dir"
      add_paths = Array.new
      path = @mirror_dir
      while url_parts_num < url_parts.size
        path += '/' + url_parts[url_parts_num]
        Dir.mkdir path
        system3 "#{svn} add #{path}"
        add_paths << path
        url_parts_num += 1
      end
      system3 "#{svn} commit -m 'yggdrasil init' --no-auth-cache --non-interactive" +
                  " --username '#{options[:username]}' --password '#{options[:password]}'" +
                  ' ' + add_paths.join(' ')
      system3 "rm -rf #@mirror_dir"
    end

    File.open(@config_file, "w") do |f|
      f.write "path=#{ENV['PATH']}\n"\
              "svn=#{svn}\n"\
              "svn_version=#{svn_version}\n"\
              "repo=#{options[:repo]}\n"
    end

    `rm -rf #@mirror_dir`
    system3 "#{svn} checkout"\
            " --no-auth-cache --non-interactive"\
            " --username '#{options[:username]}' --password '#{options[:password]}'"\
            " #{options[:repo]} #@mirror_dir"
  end
end
