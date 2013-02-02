class YggdrasilServer
  def get_ro_id_pw(sock, arg_hash = {})
    sock.puts @ro_username
    sock.puts @ro_password
    arg_hash
  end
end
