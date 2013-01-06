class Yggdrasil

  HELP_GLOBAL_OPTIONS = <<"EOS"
Global options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
EOS

  HELP_SUBCOMMANDS = <<EOS
usage: #{CMD} <subcommand> [options] [args]
Yggdrasil version #{VERSION}
Type '#{CMD} help <subcommand>' for help on a specific subcommand.

Available subcommands:
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

  # @param [Array] args
  def Yggdrasil.help(args)
    if args.size == 0 then
      puts HELP_SUBCOMMANDS
    elsif args.size != 1 then
      command_error "too many arguments."
    else
      case args[0]
        when 'add'
          puts <<"EOS"
add: Add files to management list(subversion)
usage #{CMD} add [OPTIONS...] [FILES...]

#{HELP_GLOBAL_OPTIONS}
EOS
        when 'cleanup'
          puts <<"EOS"
EOS
        when 'commit', 'ci'
          puts <<"EOS"
EOS
        when 'diff', 'di'
          puts <<"EOS"
EOS
        when 'help', '?', 'h'
          puts <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #{CMD} help [SUBCOMMAND]

EOS
        when 'init'
          puts <<"EOS"
init: Check environment and initialize configuration.
usage: #{CMD} init [OPTIONS...]

Valid options:
  --repo ARG               : specify svn repository

#{HELP_GLOBAL_OPTIONS}
EOS
        when 'list', 'ls'
          puts <<"EOS"
EOS
        when 'log'
          puts <<"EOS"
EOS
        when 'status', 'stat', 'st'
          puts <<"EOS"
EOS
        when 'revert'
          puts <<"EOS"
EOS
        when 'update'
          puts <<"EOS"
EOS
        when 'version', '--version'
          puts <<"EOS"
version: See the program version
usage: #{CMD} version

EOS
        else
          command_error "Unknown subcommand: '#{subcommand}'"
      end
    end
  end
end
