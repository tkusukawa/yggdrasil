class YggdrasilServer
  def get_configs(sock, arg_hash)
    msg = @repo + "\n"
    if @ro_username
      msg += @ro_username + "\n"
      msg += @ro_password + "\n"
    end
    sock.write obfuscate(msg, arg_hash[:key_str])
    arg_hash
  end
end