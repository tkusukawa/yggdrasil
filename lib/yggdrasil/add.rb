class Yggdrasil

  # @param [Array] args
  def add(args)
    parse_options(args, {})
    error "invalid options: #{(@arg_options).join(', ')}" if @arg_options.size != 0

    while (arg = @arg_paths.shift)

      if arg =~ /^\//
        file_path = arg
      else
        file_path = `pwd`.chomp + '/' + arg
      end
      unless File.exist?(file_path)
        puts "no such file: #{file_path}"
        next
      end
      mirror_path = @mirror_dir
      file_path_parts = file_path.split('/')[1..-1]
      file_path_parts.each do |part|
        mirror_path += "/#{part}"
        next if File.exist?(mirror_path)
        if part.equal?(file_path_parts[-1]) && File.file?(file_path)
          FileUtils.copy_file file_path, mirror_path
        else
          Dir.mkdir mirror_path
        end
        cmd = "#{@svn} add #{mirror_path}"
        cmd += ' ' + @arg_options.join(' ') if @arg_options.size != 0
        puts system3(cmd)
      end
    end
  end
end
