class Yggdrasil
  VERSION = "0.0.0"

  def Yggdrasil.version
    cmd = File::basename($0)
    puts <<"EOS"
#{cmd}, version #{VERSION}

Copyright (C) 2012-2013 Tomohisa Kusukawa.
Yggdrasil is open source software, see https://github.com/tkusukawa/yggdrasil/
EOS
  end
end
