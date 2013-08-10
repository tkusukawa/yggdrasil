class Yggdrasil

  # @param [Array] args
  def help(args)
    if args.size == 0
      puts <<EOS
usage: #@base_cmd <subcommand> [options] [args]
Yggdrasil version #{VERSION}
Type '#@base_cmd help <subcommand>' for help on a specific subcommand.

Available subcommands:
   add
   check (c, status, stat, st)
   cleanup
   commit (ci)
   diff (di)
   help (?, h)
   init
   list (ls)
   log
   update (up, revert)
   version

Yggdrasil is a subversion wrapper to manage server configurations and conditions.
At first, you should type '#@base_cmd init' to create config file.

EOS
    elsif args.size != 1 then
      error 'too many arguments.'
    else
      case args[0]
        when 'add'
          puts <<"EOS"
add: Add files to management list (add to subversion)
usage #@base_cmd add [FILES...]

EOS

        when 'check', 'c', 'status', 'stat', 'st' # check (c, status, stat, st)
          puts <<"EOS"
check (c, status, stat, st): check updating of managed files and the execution output of a commands.
usage: #@base_cmd check [OPTIONS...]

  This subcommand execute the executable files in ~/.yggdrasil/checker/, and
  the outputs are checked difference to repository with other managed files.
  For example, mount status, number of specific process and etc. can be checked
  by setting up executable files in ~/.yggdrasil/checker/

  If the yggdrasil server is registered,
  this subcommand send the result to yggdrasil server
  and yggdrasil server record the results for all managed servers.
  Type 'yggserve help', if you need to know about yggdrasil server.

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'cleanup' ################################################ cleanup
          puts <<"EOS"
cleanup: clean up the working copy
usage: #@base_cmd cleanup [OPTIONS...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
        when 'commit', 'ci' ####################################### commit (ci)
          puts <<"EOS"
commit (ci): Send changes from your local file to the repository.
usage: #@base_cmd commit [OPTIONS...] [FILES...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -m [--message] ARG       : specify log message ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'diff', 'di' ########################################### diff (di)
          puts <<"EOS"
diff (di): Display the differences between two revisions or paths.
usage: #@base_cmd diff [OPTIONS...] [PATH...]

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
        when 'help', '--help', 'h', '-h', '?' ###################### help (?,h)
          puts <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #@base_cmd help [SUBCOMMAND]

EOS
        when 'init' ###################################################### init
          puts <<"EOS"
init: Check environment and initialize configuration.
usage: #@base_cmd init [OPTIONS...]

Valid options:
  --repo ARG               : specify svn repository URL
                             ARG could be any of the following:
                             file:///*   : local repository
                             svn://*     : svn access repository
                             http(s)://* : http access repository
                             private     : make local repository in ~/.yggdrasil
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --server ARG             : specify a server address and port
                             e.g. 192.168.1.35:4000
                             see also 'yggserve help'
  --force                  : force operation to run

EOS
        when 'list', 'ls' ########################################### list (ls)
          puts <<"EOS"
list (ls): List directory entries in the repository.
usage: #@base_cmd list [OPTIONS...] [PATH...]

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
  -R [--recursive]         : descend recursively

EOS
        when 'log' ######################################################## log
          puts <<"EOS"
log: Show the log messages for a set of revision(s) and/or file(s).
usage: #@base_cmd log [OPTIONS...] [PATH]

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
  -q [--quiet]             : print nothing, or only summary information
  -v [--verbose]           : print extra information

EOS
        when 'update', 'up', 'revert' ##################### update (up, revert)
          puts <<"EOS"
update (up, revert): Set the files to the contents of the newest repository.
usage: #@base_cmd update [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --non-interactive        : do no interactive prompting
  -r [--revision] ARG      : revision number

EOS

        when 'version', '--version', '-v' ######################## version (-v)
          puts <<"EOS"
version: See the program version
usage: #@base_cmd version

EOS
        else
          error "Unknown subcommand: '#{args[0]}'"
      end
    end
  end
end
