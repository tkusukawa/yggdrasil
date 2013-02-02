class YggdrasilServer
  def put_result(sock, arg_hash = {})
    result_string = ""
    while (line=sock.gets)
      result_string << line
    end
    # make result file
    Dir.mkdir @results_dir, 0755 unless File.exist?(@results_dir)
    result_file = "#@results_dir/#{arg_hash[:hostname]}_#{sock.peeraddr[3]}"
    File.delete result_file if File.exist?(result_file)
    File.open(result_file, "w") do |f|
      f.write result_string
    end
    arg_hash
  end
end
