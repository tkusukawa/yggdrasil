class YggdrasilServer
  def get_ro_id_pw(sock, arg_hash = {})
    if @ro_username
      sock.puts @ro_username
      sock.puts @ro_password
    end
    arg_hash
  end
end
