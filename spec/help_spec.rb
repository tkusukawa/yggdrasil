require File.dirname(__FILE__) + '/../lib/yggdrasil'

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
    $stdout = StringIO.new
    Yggdrasil.command []
    $stdout.string.should == show_subcommands
  end

  it 'should show subcommands on "help"' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help}
    $stdout.string.should == show_subcommands
  end

  it 'should show subcommands on "h"' do
    $stdout = StringIO.new
    Yggdrasil.command %w{h}
    $stdout.string.should == show_subcommands
  end

  it 'should show subcommands on "?"' do
    $stdout = StringIO.new
    Yggdrasil.command %w{?}
    $stdout.string.should == show_subcommands
  end

  it 'should be unknown subcommand on "hoge"' do
    $stdout = StringIO.new
    lambda{Yggdrasil.command(%w{hoge})}.should raise_error(SystemExit)
    $stdout.string.should ==
        "#{File.basename($0)} error: Unknown subcommand: 'hoge'\n\n"
  end

  help_help = <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #{File.basename($0)} help [SUBCOMMAND]

EOS

  it 'should show help_help' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help help}
    $stdout.string.should == help_help
  end

  it 'should error too many arguments' do
    $stdout = StringIO.new
    lambda{Yggdrasil.command(%w{help help help})}.should raise_error(SystemExit)
    $stdout.string.should == <<"EOS"
#{File.basename($0)} error: too many arguments.

EOS
  end

  it 'should show help of version' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help version}
    $stdout.string.should == <<"EOS"
version: See the program version
usage: #{File.basename($0)} version

EOS
  end

  it 'should show help of init' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help init}
    $stdout.string.should == <<"EOS"
init: Check environment and initialize configuration.
usage: #{File.basename($0)} init [OPTIONS...]

Valid options:
  --repo ARG               : specify svn repository
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of add' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help add}
    $stdout.string.should == <<"EOS"
add: Add files to management list (add to subversion)
usage #{File.basename($0)} add [FILES...]

EOS
  end

  it 'should show help of commit' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help commit}
    $stdout.string.should == <<"EOS"
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
    $stdout = StringIO.new
    Yggdrasil.command %w{help cleanup}
    $stdout.string.should == <<"EOS"
cleanup: clean up the working copy
usage: #{File.basename($0)} cleanup [OPTIONS...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

  it 'should show help of diff' do
    $stdout = StringIO.new
    Yggdrasil.command %w{help diff}
    $stdout.string.should == <<"EOS"
diff (di): Display the differences between two revisions or paths.
usage: #{File.basename($0)} diff [-r N[:M]] [PATH...]

Valid options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG

EOS
  end

end
