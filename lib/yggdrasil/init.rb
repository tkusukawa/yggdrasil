
class Yggdrasil

  # @param [Array] args
  def Yggdrasil.init(args)
    arg_hash=Hash.new
    while args.size!=0 do
      option=args.shift
      case option
        when '--repo'
          command_error "Not enough arguments provided: #{option}" if args.empty?
          arg_hash[:repo]=args.shift
        else
          command_error "invalid option: #{option}"
      end
    end


    out = exec_command 'which svn'
    svn_path = out.chomp

    out = exec_command 'svn --version'
    unless /version (\d+\.\d+\.\d+) / =~ out then
      puts "#{CMD} error: can not find version string: svn --version"
      exit 1
    end
    svn_version=$1

    p [svn_path, svn_version]

    config_dir =  ENV["HOME"] + '/.yggdrasil'
    if File.exist?(config_dir) then
      puts "#{CMD} error: already exist .yggdrasil directory: #{config_dir}"
      exit 1
    end

    until arg_hash.has_key?(:repo) do
      print "Input svn repo:"
      input = $stdin.gets
      arg_hash[:repo] = input.chomp if /^A/ =~ input
    end

    Dir.mkdir(config_dir, 0755)
    File.write(config_dir+'/config', <<"EOS"
repo=#{arg_hash[:repo]}
path=#{ENV["PATH"]}
svn_path=#{svn_path}
svn_version=#{svn_version}
EOS
    )

    puts "RES=#{$?}"
    puts "pwd=#{Dir::pwd}"
    puts "HOME=#{ENV["HOME"]}"
    puts `which svn`
    ENV["PATH"] += ":/hoge"

  end
end
