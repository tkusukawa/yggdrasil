require 'nkf'

class YggdrasilServer

  # @param [Array] args
  def results(args)
    parse_options(args, {'--expire'=>:expire})

    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    return unless File.exist?(@results_dir)
    files = Dir.entries(@results_dir)
    alert = false
    files.each do |file|
      next if /^\./ =~ file
      absolute = "#{@results_dir}/#{file}"
      if @options.has_key?(:expire)
        stat = File.stat(absolute)
        if stat.mtime < (Time.now - @options[:expire].to_i * 60)
          alert = true
          puts "######## #{file}: last check is too old: #{stat.mtime.to_s}"
          puts
          next
        end
      end
      buf = File.read("#{@results_dir}/#{file}")
      buf = NKF::nkf('-wm0', buf)
      if buf.gsub(/\s*\n/m, '') != ''
        alert = true
        puts "######## #{file} Mismatch:"
        puts buf
      end
    end
    exit 1 if alert
  end
end
