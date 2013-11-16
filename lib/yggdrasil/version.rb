class Yggdrasil
  VERSION = '0.0.18.1'

  def version
    puts <<"EOS"
#{@base_cmd}, version #{VERSION}

Copyright (C) 2012-2013 Tomohisa Kusukawa.
Yggdrasil is open source software, see https://github.com/tkusukawa/yggdrasil/

EOS
  end
end
