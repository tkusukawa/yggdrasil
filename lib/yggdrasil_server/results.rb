class YggdrasilServer

  # @param [Array] args
  def results(args)
    args = parse_options(args, {'--limit'=>:limit})

    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    return unless File.exist?(@results_dir)
    files = Dir.entries(@results_dir)
    files.each do |file|
      next if /^\./ =~ file
      absolute = "#@results_dir/#{file}"
      if @options.has_key?(:limit)
        stat = File.stat(absolute)
        if stat.mtime < (Time.now - @options[:limit].to_i * 60)
          puts "######## #{file} TOO OLD: #{stat.mtime.to_s}"
          next
        end
      end
      buf = File.read("#@results_dir/#{file}")
      if buf.gsub(/\s*\n/m, '') != ''
        puts "######## #{file} Mismatch:"
        puts buf
      end
    end
  end
end
