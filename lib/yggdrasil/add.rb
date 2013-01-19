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
      file_path_parts = file_path.split('/')[1..-1]
      file_path_parts.each do |part|
        mirror_path += "/#{part}"
        next if File.exist?(mirror_path)
        if part.equal?(file_path_parts[-1])
          FileUtils.copy file_path, mirror_path
        else
          Dir.mkdir mirror_path
        end
        puts system3("#@svn add #{mirror_path}")
      end
    end
  end
end
