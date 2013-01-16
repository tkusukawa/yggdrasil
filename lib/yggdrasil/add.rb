class Yggdrasil

  # @param [Array] args
  def add(args)
    while (arg = args.shift)
      file_path = `readlink -f #{arg}`.chomp
      exit $?.exitstatus unless $?.success?
      unless File.exist?(file_path)
        puts "no such file: #{file_path}"
        next
      end
      mirror_path = @mirror_dir
      file_path.split('/')[1..-1].each do |part|
        mirror_path += '/'+part
        next if File.exist?(mirror_path)
        if mirror_path == @mirror_dir+file_path
          FileUtils.copy file_path, mirror_path
        else
          Dir.mkdir mirror_path
        end
        puts system3("#@svn add --no-auth-cache --non-interactive #{mirror_path}")
      end
    end
  end
end
