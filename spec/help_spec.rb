require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "help" do
  puts '-------- help'

  show_subcommands = <<"EOS"
usage: #{File.basename($0)} <subcommand> [options] [args]
Yggdrasil version #{Yggdrasil::VERSION}
Type '#{File.basename($0)} help <subcommand>' for help on a specific subcommand.

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

  it 'should show subcommands on no subcommands' do
    puts '---- should show subcommands on no subcommands'
    out = catch_out{Yggdrasil.command []}
    out.should == show_subcommands
  end

  it 'should show subcommands on "help"' do
    puts '---- should show subcommands on "help"'
    out = catch_out{Yggdrasil.command %w{help}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "h"' do
    puts '---- should show subcommands on "h"'
    out = catch_out{Yggdrasil.command %w{h}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "?"' do
    puts '---- should show subcommands on "?"'
    out = catch_out{Yggdrasil.command %w{?}}
    out.should == show_subcommands
  end

  it 'should be unknown subcommand on "hoge"' do
    puts '---- should be unknown subcommand on "hoge"'
    err = catch_err do
      lambda{Yggdrasil.command(%w{hoge})}.should raise_error(SystemExit)
    end
    err.should == "Unknown subcommand: 'hoge'\n"
  end

  help_help = <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #{File.basename($0)} help [SUBCOMMAND]

EOS

  it 'should show help_help' do
    puts '---- should show help_help'
    out = catch_out{Yggdrasil.command %w{help help}}
    out.should == help_help
  end

  it 'should error too many arguments' do
    puts '---- should error too many arguments'
    err = catch_err do
      lambda{Yggdrasil.command(%w{help help help})}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: too many arguments.\n\n"
  end

  it 'should show help of version' do
    puts '---- should show help of version'
    out = catch_out{Yggdrasil.command %w{help version}}
    out.should == <<"EOS"
version: See the program version
usage: #{File.basename($0)} version

EOS
  end

  it 'should show help of init' do
    puts '---- should show help of init'
    out = catch_out{Yggdrasil.command %w{help init}}
    out.should == <<"EOS"
init: Check environment and initialize configuration.
usage: #{File.basename($0)} init [OPTIONS...]

Valid options:
  --repo ARG               : specify svn repository URL
                             ARG could be any of the following:
                             file:///*   : local repository
                             svn://*     : svn access repository
                             http(s)://* : http access repository
                             private     : make local repository in ~/.yggdrasil
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of add' do
    puts '---- should show help of add'
    out = catch_out{Yggdrasil.command %w{help add}}
    out.should == <<"EOS"
add: Add files to management list (add to subversion)
usage #{File.basename($0)} add [FILES...]

EOS
  end

  it 'should show help of commit' do
    puts '---- should show help of commit'
    out = catch_out{Yggdrasil.command %w{help commit}}
    out.should == <<"EOS"
commit (ci): Send changes from your local file to the repository.
usage: #{File.basename($0)} commit [OPTIONS...] [FILES...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  -m [--message] ARG       : specify log message ARG
  --non-interactive        : do no interactive prompting

EOS
  end

  it 'should show help of cleanup' do
    puts '---- should show help of cleanup'
    out = catch_out{Yggdrasil.command %w{help cleanup}}
    out.should == <<"EOS"
cleanup: clean up the working copy
usage: #{File.basename($0)} cleanup [OPTIONS...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of diff' do
    puts '---- should show help of diff'
    out = catch_out{Yggdrasil.command %w{help diff}}
    out.should == <<"EOS"
diff (di): Display the differences between two revisions or paths.
usage: #{File.basename($0)} diff [OPTIONS...] [PATH...]

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
  end

  it 'should show help of list' do
    puts '---- should show help of list'
    out = catch_out{Yggdrasil.command %w{help list}}
    out.should == <<"EOS"
list (ls): List directory entries in the repository.
usage: #{File.basename($0)} list [OPTIONS...] [PATH...]

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
  end

  it 'should show help of log' do
    puts '---- should show help of log'
    out = catch_out{Yggdrasil.command %w{help log}}
    out.should == <<"EOS"
log: Show the log messages for a set of revision(s) and/or file(s).
usage: #{File.basename($0)} log [OPTIONS...] [PATH]

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
  end

  it 'should show help of status' do
    puts '---- should show help of status'
    out = catch_out{Yggdrasil.command %w{help status}}
    out.should == <<"EOS"
status (stat, st): Print the status of managed files and directories.
usage: #{File.basename($0)} status [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of update' do
    puts '---- should show help of update'
    out = catch_out{Yggdrasil.command %w{help update}}
    out.should == <<"EOS"
update (up): Bring changes from the repository into the local files.
usage: #{File.basename($0)} update [OPTIONS...] [PATH...]

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
  end

  it 'should show help of revert' do
    puts '---- should show help of revert'
    out = catch_out{Yggdrasil.command %w{help revert}}
    out.should == <<"EOS"
revert: Restore pristine working copy file (undo most local edits).
usage: #{File.basename($0)} revert [OPTIONS...] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
  --non-interactive        : do no interactive prompting

EOS
  end

  it 'should show help of check' do
    puts '---- should show help of check'
    out = catch_out{Yggdrasil.command %w{help check}}
    out.should == <<"EOS"
check (c): check updating of managed files and the execution output of a commands.
usage: #{File.basename($0)} check [OPTIONS...]

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
  end

  it 'should show help of init-server' do
    puts '---- should show help of init-server'
    out = catch_out{Yggdrasil.command %w{help init-server}}
    out.should == <<"EOS"
init-server: setup server configuration.
usage: #{File.basename($0)} init-server [OPTIONS...]

Valid options:
  --port ARG               : specify a TCP port number ARG
  --repo ARG               : URL of subversion repository
                             ARG could be include {HOST} and it replace by client hostname
                             e.g. svn://192.168.3.5/servers/{HOST}/ygg
  --ro-username ARG        : specify a username ARG for read only
  --ro-password ARG        : specify a password ARG for read only

EOS
  end

  it 'should show help of server' do
    puts '---- should show help of server'
    out = catch_out{Yggdrasil.command %w{help server}}
    out.should == <<"EOS"
server: receive tcp connection in order to unify the setup and to record check results.
usage: #{File.basename($0)} server [OPTIONS...]

Valid options:
  --daemon                 : daemon mode

EOS
  end

  it 'should show help of results' do
    puts '---- should show help of results'
    out = catch_out{Yggdrasil.command %w{help results}}
    out.should == <<"EOS"
results: display the result of yggdrasil check command.
usage: #{File.basename($0)} results [OPTIONS...]

Valid options:
  --limit ARG              : minutes from the final report, to judge the host not be alive

EOS
  end
end
