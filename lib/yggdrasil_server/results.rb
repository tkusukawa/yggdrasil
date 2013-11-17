require 'nkf'

class YggdrasilServer

  # @param [Array] args
  def results(args)
    parse_options(args, {'--expire'=>:expire})

    if @arg_options.size+@arg_paths.size != 0
      error "invalid arguments: #{(@arg_options+@arg_paths).join(', ')}"
    end

    error 'NO results directory' unless File.exist?(@results_dir)

    repo_base = @repo
    repo_base.gsub!(/\{HOST\}.*$/,'') if @repo =~ /\{HOST\}/
    repo_base.gsub!(/\{host\}.*$/,'') if @repo =~ /\{host\}/

    cmd = "svn ls #{repo_base} --no-auth-cache --non-interactive"
    cmd += " --username #{@ro_username} --password #{@ro_password}" if @ro_username
    out = system3(cmd)
    repo_hosts = Hash.new
    out.split(/\n/).each do |host|
      next if host =~ /^[_\.]/
      repo_hosts[host.gsub(/\/$/, '')] = true
    end

    files = Dir.entries(@results_dir)
    alert = false
    files.each do |file|
      next if /^\./ =~ file
      absolute = "#{@results_dir}/#{file}"
      host = file.gsub(/_[^_]+$/,'')
      if repo_hosts.has_key?(host)
        repo_hosts.delete host
      else
        # There is no host in the REPO
        puts "WARNING: delete result file (#{file})"
        puts
        File.unlink absolute # delete result file
        next
      end
      if @options.has_key?(:expire)
        stat = File.stat(absolute)
        if stat.mtime < (Time.now - @options[:expire].to_i * 60)
          alert = true
          puts "######## Expired: #{file} (#{stat.mtime.to_s})"
          puts
          next
        end
      end
      buf = File.read("#{@results_dir}/#{file}")
      buf = NKF::nkf('-wm0', buf)
      if buf.gsub(/\s*\n/m, '') != ''
        alert = true
        puts "######## Difference: #{file}"
        puts buf
      end
    end

    repo_hosts.each do |k,v|
      if v
        alert = true
        puts "######## No check result: #{k}"
        puts
      end
    end
    exit 1 if alert
  end
end
