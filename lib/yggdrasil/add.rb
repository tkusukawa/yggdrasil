class Yggdrasil

  # @param [Array] args
  def add(args)

    while (arg = args.shift)
      file_path = `readlink -f #{arg}`.chomp
      unless File.exist?(file_path)
        puts "no such file: #{file_path}"
        next
      end
      mirror_path = @mirror_dir + file_path
      mirror_dir = File.dirname(mirror_path)
      FileUtils.mkdir_p(mirror_dir) unless File.exist?(mirror_dir)
      FileUtils.copy(file_path, mirror_path)
      puts Yggdrasil.exec_command("#{ @svn } add --parents #{mirror_path}")
    end
  end
end
