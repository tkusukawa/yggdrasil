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
   check (c)
   cleanup
   commit (ci)
   diff (di)
   help (?, h)
   init
   init-server
   list (ls)
   log
   results
   revert
   server
   status (stat, st)
   update
   version

Yggdrasil is a subversion wrapper to manage server configurations and conditions.
You should type 'yggdrasil init' at first.

EOS
    elsif args.size != 1 then
      error "too many arguments."
    else
      case args[0]
        when 'add'
          puts <<"EOS"
add: Add files to management list (add to subversion)
usage #@base_cmd add [FILES...]

EOS
        when 'check', 'c'
          puts <<"EOS"
check (c): check updating of managed files and the execution output of a commands.
usage: #@base_cmd check [OPTIONS...]

  This subcommand execute the executable files in ~/.yggdrasil/checker/, and
  the outputs are checked difference to repository with other managed files.
  For example, mount status, number of specific process and etc. can be checked
  by setting up executable files in ~/.yggdrasil/checker/

  if the server is registered, the yggdrasil server receive and record the results.

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'cleanup'
          puts <<"EOS"
cleanup: clean up the working copy
usage: #@base_cmd cleanup [OPTIONS...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
        when 'commit', 'ci'
          puts <<"EOS"
commit (ci): Send changes from your local file to the repository.
usage: #@base_cmd commit [OPTIONS...] [FILES...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -m [--message] ARG       : specify log message ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'diff', 'di'
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
        when 'help', '?', 'h'
          puts <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #@base_cmd help [SUBCOMMAND]

EOS
        when 'init'
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

EOS
        when 'init-server'
          puts <<"EOS"
init-server: setup server configuration.
usage: #@base_cmd init-server [OPTIONS...]

Valid options:
  --port ARG               : specify a TCP port number ARG
  --repo ARG               : URL of subversion repository
                             ARG could be include {HOST} and it replace by client hostname
                             e.g. svn://192.168.3.5/servers/{HOST}/ygg
  --ro-username ARG        : specify a username ARG for read only
  --ro-password ARG        : specify a password ARG for read only

EOS
        when 'list', 'ls'
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
        when 'log'
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

EOS
        when 'results'
          puts <<"EOS"
results: display the result of yggdrasil check command.
usage: #@base_cmd results [OPTIONS...]

Valid options:
  --limit ARG              : minutes from the final report, to judge the host not be alive

EOS
        when 'revert'
          puts <<"EOS"
revert: Restore pristine working copy file (undo most local edits).
usage: #@base_cmd revert [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --non-interactive        : do no interactive prompting

EOS
        when 'server'
          puts <<"EOS"
server: receive tcp connection in order to unify the setup and to record check results.
usage: #@base_cmd server [OPTIONS...]

Valid options:
  --daemon                 : daemon mode

EOS
        when 'status', 'stat', 'st'
          puts <<"EOS"
status (stat, st): Print the status of managed files and directories.
usage: #@base_cmd status [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
        when 'update'
          puts <<"EOS"
update (up): Bring changes from the repository into the local files.
usage: #@base_cmd update [OPTIONS...] [PATH...]

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
  --non-interactive        : do no interactive prompting

EOS
        when 'version', '--version'
          puts <<"EOS"
version: See the program version
usage: #@base_cmd version

EOS
        else
          error "Unknown subcommand: '#{subcommand}'"
      end
    end
  end
end
