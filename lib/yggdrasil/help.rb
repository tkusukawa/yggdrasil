class Yggdrasil

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
You should type 'yggdrasil init' at first.

EOS

  # @param [Array] args
  def Yggdrasil.help(args)
    if args.size == 0 then
      puts HELP_SUBCOMMANDS
    elsif args.size != 1 then
      error "too many arguments."
    else
      case args[0]
        when 'add'
          puts <<"EOS"
add: Add files to management list (add to subversion)
usage #{CMD} add [FILES...]

EOS
        when 'cleanup'
          puts <<"EOS"
cleanup: clean up the working copy
usage: #{CMD} cleanup [OPTIONS...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
        when 'commit', 'ci'
          puts <<"EOS"
commit (ci): Send changes from your local file to the repository.
usage: #{CMD} commit [OPTIONS...] [FILES...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -m [--message] ARG       : specify log message ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'diff', 'di'
          puts <<"EOS"
diff (di): Display the differences between two revisions or paths.
usage: #{CMD} diff [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -r [--revision] ARG      : ARG (some commands also take ARG1:ARG2 range)
                             A revision argument can be one of:
                                NUMBER       revision number
                                '{' DATE '}' revision at start of the date
                                'HEAD'       latest in repository
                                'BASE'       base rev of item's working copy
                                'COMMITTED'  last commit at or before BASE
                                'PREV'       revision just before COMMITTED

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
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
        when 'list', 'ls'
          puts <<"EOS"
list (ls): List directory entries in the repository.
usage: #{CMD} list [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -r [--revision] ARG      : ARG (some commands also take ARG1:ARG2 range)
                             A revision argument can be one of:
                                NUMBER       revision number
                                '{' DATE '}' revision at start of the date
                                'HEAD'       latest in repository
                                'BASE'       base rev of item's working copy
                                'COMMITTED'  last commit at or before BASE
                                'PREV'       revision just before COMMITTED
  -R [--recursive]         : descend recursively, same as --depth=infinity
  --depth ARG              : limit operation by depth ARG ('empty', 'files',
                            'immediates', or 'infinity')
EOS
        when 'log'
          puts <<"EOS"
log: Show the log messages for a set of revision(s) and/or file(s).
usage: #{CMD} log [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -r [--revision] ARG      : ARG (some commands also take ARG1:ARG2 range)
                             A revision argument can be one of:
                                NUMBER       revision number
                                '{' DATE '}' revision at start of the date
                                'HEAD'       latest in repository
                                'BASE'       base rev of item's working copy
                                'COMMITTED'  last commit at or before BASE
                                'PREV'       revision just before COMMITTED
EOS
        when 'status', 'stat', 'st'
          puts <<"EOS"
Sorry.
Under construction.
EOS
        when 'revert'
          puts <<"EOS"
Sorry.
Under construction.
EOS
        when 'update'
          puts <<"EOS"
Sorry.
Under construction.
EOS
        when 'version', '--version'
          puts <<"EOS"
version: See the program version
usage: #{CMD} version

EOS
        else
          error "Unknown subcommand: '#{subcommand}'"
      end
    end
  end
end
