class YggdrasilServer
  def get_repo(sock, arg_hash = {})
    sock.puts @repo
    arg_hash
  end
end
