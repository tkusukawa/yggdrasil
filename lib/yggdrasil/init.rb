class Yggdrasil

  # @param [Array] args
  def init(args)

    args = parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '--repo'=>:repo, '--parents'=>:parents?, '--non-interactive'=>:non_interactive?})
    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    out = system3 'which svn'
    svn = out.chomp

    out = system3 'svn --version'
    error "can not find version string: svn --version" unless /version (\d+\.\d+\.\d+) / =~ out
    svn_version=$1

    error "already exist config file: #@config_file" if File.exist?(@config_file)

    until @options.has_key?(:repo) do
      print "Input svn repo URL: "
      input = $stdin.gets
      error "can not input svn repo URL" unless input

      unless %r{^(http://|https://|file://|svn://|private)} =~ input
        puts "ERROR: Invalid URL."
        redo
      end
      @options[:repo] = input
    end
    @options[:repo].chomp!
    @options[:repo].chomp!('/')
    if @options[:repo] == "private"
      Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)
      repo_dir = "#@config_dir/private_repo"
      system3 "svnadmin create #{repo_dir}"
      @options[:repo] = "file://#{repo_dir}"
    end

    puts "check SVN access..."
    url_parts = @options[:repo].split('/')
    url_parts_num = url_parts.size
    anon_access = true
    loop do
      if url_parts_num < 3
        if anon_access
          anon_access = false
          url_parts_num = url_parts.size
          input_user_pass
        else
          error "can not access to '#{@options[:repo]}'."
        end
      end
      puts "url_parts_num=#{url_parts_num}" if @options[:debug?]

      url = url_parts[0...url_parts_num].join('/')
      puts "try url=#{url}" if @options[:debug?]
      cmd = "#{svn} ls --no-auth-cache --non-interactive #{url}"
      cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless anon_access
      ret = system3(cmd, false)
      unless ret.nil?
        puts "SVN access OK: #{url}"
        break
      end

      url_parts_num -= 1
    end

    Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)

    if url_parts_num != url_parts.size
      until @options[:parents?]
        msg = "not exist directory(s): #{url_parts[url_parts_num...url_parts.size].join('/')}"
        error msg if @options[:non_interactive?]
        puts msg
        print "make directory(s)? [Yn]: "
        input = $stdin.gets
        error "can not gets $stdin" if input.nil?
        input.chomp!
        return if input == 'n'
        break if input == 'Y'
      end
      input_user_pass
      `rm -rf #@mirror_dir`
      system3 "#{svn} checkout --no-auth-cache --non-interactive" +
                  " --username '#{@options[:username]}' --password '#{@options[:password]}'" +
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
                  " --username '#{@options[:username]}' --password '#{@options[:password]}'" +
                  ' ' + add_paths.join(' ')
      system3 "rm -rf #@mirror_dir"
    end

    # make config file
    File.open(@config_file, "w") do |f|
      f.write "path=#{ENV['PATH']}\n"\
              "svn=#{svn}\n"\
              "svn_version=#{svn_version}\n"\
              "repo=#{@options[:repo]}\n"\
              "anon-access=#{anon_access ? 'read' : 'none'}\n"
    end

    # make mirror dir
    `rm -rf #@mirror_dir`
    cmd = "#{svn} checkout --no-auth-cache --non-interactive #{@options[:repo]} #@mirror_dir"
    cmd += " --username '#{@options[:username]}' --password '#{@options[:password]}'" unless anon_access
    system3 cmd

    # make checker dir and checker example
    Dir.mkdir @checker_dir, 0755 unless File.exist?(@checker_dir)
    FileUtils.cd @checker_dir do
      `echo 'gem list' > gem_list`
      `chmod +x gem_list`
    end
  end
end
