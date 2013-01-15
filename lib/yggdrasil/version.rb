class Yggdrasil
  VERSION = "0.0.2"
  CMD = File::basename($0)

  def Yggdrasil.version
    puts <<"EOS"
#{CMD}, version #{VERSION}

Copyright (C) 2012-2013 Tomohisa Kusukawa.
Yggdrasil is open source software, see https://github.com/tkusukawa/yggdrasil/

EOS
  end
end
