class YggdrasilServer
  def get_configs(sock, arg_hash)
    key = make_key(arg_hash[:key_str])
    msg = @repo + "\n"
    if @ro_username
      msg += @ro_username + "\n"
      msg += @ro_password + "\n"
    end
    sock.write obfuscate(msg, key)
    arg_hash
  end
end