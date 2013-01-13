require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "help" do

  show_subcommands = <<"EOS"
usage: #{File.basename($0)} <subcommand> [options] [args]
Yggdrasil version #{Yggdrasil::VERSION}
Type '#{File.basename($0)} help <subcommand>' for help on a specific subcommand.

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

  it 'should show subcommands on no subcommands' do
    puts '---- should show subcommands on no subcommands'
    out = catch_stdout{Yggdrasil.command []}
    out.should == show_subcommands
  end

  it 'should show subcommands on "help"' do
    puts '---- should show subcommands on "help"'
    out = catch_stdout{Yggdrasil.command %w{help}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "h"' do
    puts '---- should show subcommands on "h"'
    out = catch_stdout{Yggdrasil.command %w{h}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "?"' do
    puts '---- should show subcommands on "?"'
    out = catch_stdout{Yggdrasil.command %w{?}}
    out.should == show_subcommands
  end

  it 'should be unknown subcommand on "hoge"' do
    puts '---- should be unknown subcommand on "hoge"'
    out = catch_stdout do
      lambda{Yggdrasil.command(%w{hoge})}.should raise_error(SystemExit)
    end
    out.should == "#{File.basename($0)} error: Unknown subcommand: 'hoge'\n\n"
  end

  help_help = <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #{File.basename($0)} help [SUBCOMMAND]

EOS

  it 'should show help_help' do
    puts '---- should show help_help'
    out = catch_stdout{Yggdrasil.command %w{help help}}
    out.should == help_help
  end

  it 'should error too many arguments' do
    puts '---- should error too many arguments'
    out = catch_stdout do
      lambda{Yggdrasil.command(%w{help help help})}.should raise_error(SystemExit)
    end
    out.should == "#{File.basename($0)} error: too many arguments.\n\n"
  end

  it 'should show help of version' do
    puts '---- should show help of version'
    out = catch_stdout{Yggdrasil.command %w{help version}}
    out.should == <<"EOS"
version: See the program version
usage: #{File.basename($0)} version

EOS
  end

  it 'should show help of init' do
    puts '---- should show help of init'
    out = catch_stdout{Yggdrasil.command %w{help init}}
    out.should == <<"EOS"
init: Check environment and initialize configuration.
usage: #{File.basename($0)} init [OPTIONS...]

Valid options:
  --repo ARG               : specify svn repository
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of add' do
    puts '---- should show help of add'
    out = catch_stdout{Yggdrasil.command %w{help add}}
    out.should == <<"EOS"
add: Add files to management list (add to subversion)
usage #{File.basename($0)} add [FILES...]

EOS
  end

  it 'should show help of commit' do
    puts '---- should show help of commit'
    out = catch_stdout{Yggdrasil.command %w{help commit}}
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
    out = catch_stdout{Yggdrasil.command %w{help cleanup}}
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
    out = catch_stdout{Yggdrasil.command %w{help diff}}
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
    out = catch_stdout{Yggdrasil.command %w{help list}}
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
  -R [--recursive]         : descend recursively, same as --depth=infinity
  --depth ARG              : limit operation by depth ARG ('empty', 'files',
                            'immediates', or 'infinity')
EOS
  end

  it 'should show help of log' do
    puts '---- should show help of log'
    out = catch_stdout{Yggdrasil.command %w{help log}}
    out.should == <<"EOS"
log: Show the log messages for a set of revision(s) and/or file(s).
usage: #{File.basename($0)} log [OPTIONS...] [PATH...]

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
end
