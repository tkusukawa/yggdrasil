class Yggdrasil

  # @param [Array] args
  def add(args)
    add_relatives = Array.new
    while (arg = args.shift)
      file_path = `readlink -f #{arg}`.chomp
      exit $?.exitstatus unless $?.success?
      unless File.exist?(file_path)
        puts "no such file: #{file_path}"
        next
      end
      mirror_path = @mirror_dir + file_path
      mirror_dir = File.dirname(mirror_path)
      FileUtils.mkdir_p(mirror_dir) unless File.exist?(mirror_dir)
      FileUtils.copy file_path, mirror_path
      add_relatives << file_path.sub(%r{^/}, '')
    end
    if add_relatives.size != 0
      FileUtils.cd @mirror_dir do
        puts system3("#@svn add --no-auth-cache --non-interactive --parents #{add_relatives.join(' ')}")
      end
    end
  end
end
