class YggdrasilServer

  # @param [Array] args
  def results(args)
    args = parse_options(args, {'--limit'=>:limit})

    if args.size != 0
      error "invalid arguments: #{args.join(',')}"
    end

    return unless File.exist?(@results_dir)
    files = Dir.entries(@results_dir)
    alert = false
    files.each do |file|
      next if /^\./ =~ file
      absolute = "#@results_dir/#{file}"
      if @options.has_key?(:limit)
        stat = File.stat(absolute)
        if stat.mtime < (Time.now - @options[:limit].to_i * 60)
          alert = true
          puts "######## #{file}: last check is too old: #{stat.mtime.to_s}"
          next
        end
      end
      buf = File.read("#@results_dir/#{file}")
      if buf.gsub(/\s*\n/m, '') != ''
        alert = true
        puts "######## #{file} Mismatch:"
        puts buf
      end
    end
    exit 1 if alert
  end
end
