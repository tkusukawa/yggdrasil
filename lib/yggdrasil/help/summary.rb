class Yggdrasil
  puts <<"EOS"
usage: #{CMD} <subcommand> [options] [args]
Yggdrasil version #{VERSION}
Type '#{CMD} help <subcommand>' for help on a specific subcommand.

Available subcommand:
   add
   cleanup
   commit (ci)
   diff (di)
   help (?, h)
   init
   list (ls)
   log
   status (stat, st)
   revert
   update
   version

Yggdrasil is a configuration management tool by Subversion.
EOS
end
