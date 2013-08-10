require 'socket'

class Yggdrasil

  # @param [Array] args
  def init(args)

    parse_options(args,
        {'--username'=>:username, '--password'=>:password,
         '--repo'=>:repo, '--parents'=>:parents?,
         '--non-interactive'=>:non_interactive?,
         '--force'=>:force?, '--server'=>:server })
    @options[:ro_username] = @options[:username] if @options.has_key?(:username)
    @options[:ro_password] = @options[:password] if @options.has_key?(:password)

    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    out = system3 'which svn'
    svn = out.chomp

    out = system3 'svn --version'
    error 'can not find version string: svn --version' unless /version (\d+\.\d+\.\d+) / =~ out
    svn_version=$1

    while File.exist?(@config_file)
      if @options[:force?]
        `rm -rf #@config_file`
        break
      end
      puts "Already exist config file: #@config_file"
      exit 1 if @options[:non_interactive?]
      print 'Overwrite? [Yn]: '
      res = $stdin.gets
      puts
      return nil unless res
      res.chomp!
      return nil if res == 'n'
      if res == 'Y'
        `rm -rf #@config_file`
        break
      end
    end

    get_server_config(true) if @options.has_key?(:server)

    init_get_repo_interactive unless @options.has_key?(:repo)

    @options[:repo].chomp!
    @options[:repo].chomp!('/')
    @options[:repo].gsub!(/\{HOST\}/, Socket.gethostname)
    @options[:repo].gsub!(/\{host\}/, Socket.gethostname.split('.')[0])
    if @options[:repo] == 'private'
      Dir.mkdir @config_dir, 0755 unless File.exist?(@config_dir)
      repo_dir = "#@config_dir/private_repo"
      system3 "svnadmin create #{repo_dir}"
      @options[:repo] = "file://#{repo_dir}"
    end

    puts 'check SVN access...'
    if @options.has_key?(:ro_username)
      anon_access = false
    else
      anon_access = true
    end
    url_parts = @options[:repo].split('/')
    url_parts_num = url_parts.size
    url = ''
    loop do
      if url_parts_num < 3
        if anon_access
          anon_access = false
          url_parts_num = url_parts.size
          get_user_pass_if_need_to_read_repo
        else
          error "can not access to '#{@options[:repo]}'."
        end
      end
      puts "url_parts_num=#{url_parts_num}" if @options[:debug?]

      url = url_parts[0...url_parts_num].join('/')
      puts "try url=#{url}" if @options[:debug?]
      cmd = "#{svn} ls --no-auth-cache --non-interactive #{url}"
      cmd += username_password_options_to_read_repo
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
        break if @options[:force?]
        msg = "not exist directory(s) in repository: #{url_parts[url_parts_num...url_parts.size].join('/')}"
        error msg if @options[:non_interactive?]
        puts msg
        print 'make directory(s)? [Yn]: '
        input = $stdin.gets
        error 'can not gets $stdin' if input.nil?
        puts
        input.chomp!
        return if input == 'n'
        break if input == 'Y'
      end
      input_user_pass
      `rm -rf #@mirror_dir`
      system3 "#{svn} checkout -N --no-auth-cache --non-interactive" +
                  " --username '#{@options[:ro_username]}' --password '#{@options[:ro_password]}'" +
                  " #{url_parts[0...url_parts_num].join('/')} #@mirror_dir"
      add_paths = Array.new
      path = @mirror_dir
      while url_parts_num < url_parts.size
        url += '/' + url_parts[url_parts_num]
        path += '/' + url_parts[url_parts_num]
        Dir.mkdir path
        system3 "#{svn} add #{path}"
        puts "add #{url}"
        add_paths << path
        url_parts_num += 1
      end
      system3 "#{svn} commit -m 'yggdrasil init' --no-auth-cache --non-interactive" +
                  " --username '#{@options[:username]}' --password '#{@options[:password]}'" +
                  ' ' + add_paths.join(' ')
      system3 "rm -rf #@mirror_dir"
    end

    # make config file
    File.open(@config_file, 'w') do |f|
      f.puts "path=#{ENV['PATH']}\n"\
             "svn=#{svn}\n"\
             "svn_version=#{svn_version}\n"\
             "repo=#{@options[:repo]}\n"\
             "anon-access=#{anon_access ? 'read' : 'none'}\n"
      f.puts "server=#{@options[:server]}\n" if @options.has_key?(:server)
    end

    # make mirror dir
    `rm -rf #@mirror_dir`
    cmd = "#{svn} checkout --no-auth-cache --non-interactive #{@options[:repo]} #@mirror_dir"
    cmd += " --username '#{@options[:ro_username]}' --password '#{@options[:ro_password]}'" unless anon_access
    system3 cmd

    # make checker dir and checker example
    Dir.mkdir @checker_dir, 0755 unless File.exist?(@checker_dir)
    FileUtils.cd @checker_dir do
      `echo 'gem list' > gem_list`
      `chmod +x gem_list`
    end
  end


  def init_get_repo_interactive
    loop do
      print 'Input svn repo URL: '
      input = $stdin.gets
      error 'can not input svn repo URL' unless input
      puts
      if %r{^(http://|https://|file://|svn://|private)} =~ input
        @options[:repo] = input
        break
      end

      puts 'ERROR: Invalid URL.'
    end
  end
end
