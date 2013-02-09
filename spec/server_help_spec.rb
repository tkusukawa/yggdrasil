require File.dirname(__FILE__) + '/spec_helper'
require 'yggdrasil_server'

describe YggdrasilServer, 'help (server)' do
  puts '-------- help (server)'

  show_subcommands = <<"EOS"
usage: #{File.basename($0)} <subcommand> [options] [args]
Yggdrasil version #{Yggdrasil::VERSION}
Type '#{File.basename($0)} help <subcommand>' for help on a specific subcommand.

Available subcommands:
   daemon
   debug
   help (?, h)
   init
   results
   version

Yggdrasil server is a TCP server
to receive/record the yggdrasil check result of all managed servers.

At first, you should type '#{File.basename($0)} init' to create config file.

EOS

  it 'should show subcommands on no subcommands (server)' do
    puts '---- should show subcommands on no subcommands (server)'
    out = catch_out{YggdrasilServer.command []}
    out.should == show_subcommands
  end

  it 'should show subcommands on "help" (server)' do
    puts '---- should show subcommands on "help" (server)'
    out = catch_out{YggdrasilServer.command %w{help}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "h" (server)' do
    puts '---- should show subcommands on "h" (server)'
    out = catch_out{YggdrasilServer.command %w{h}}
    out.should == show_subcommands
  end

  it 'should show subcommands on "?" (server)' do
    puts '---- should show subcommands on "?" (server)'
    out = catch_out{YggdrasilServer.command %w{?}}
    out.should == show_subcommands
  end

  it 'should be unknown subcommand on "hoge" (server)' do
    puts '---- should be unknown subcommand on "hoge" (server)'
    err = catch_err do
      lambda{YggdrasilServer.command(%w{hoge})}.should raise_error(SystemExit)
    end
    err.should == "Unknown subcommand: 'hoge'\n"
  end

  help_help = <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #{File.basename($0)} help [SUBCOMMAND]

EOS

  it 'should show help_help (server)' do
    puts '---- should show help_help (server)'
    out = catch_out{YggdrasilServer.command %w{help help}}
    out.should == help_help
  end

  it 'should error too many arguments (server)' do
    puts '---- should error too many arguments (server)'
    err = catch_err do
      lambda{YggdrasilServer.command(%w{help help help})}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: too many arguments.\n\n"
  end

  it 'should show help of version (server)' do
    puts '---- should show help of version (server)'
    out = catch_out{YggdrasilServer.command %w{help version}}
    out.should == <<"EOS"
version: See the program version
usage: #{File.basename($0)} version

EOS
  end


  it 'should show help of init (server)' do
    puts '---- should show help of init (server)'
    out = catch_out{YggdrasilServer.command %w{help init}}
    out.should == <<"EOS"
init: setup yggdrasil server configuration.
usage: #{File.basename($0)} init [OPTIONS...]

Valid options:
  --port ARG               : specify a TCP port number ARG
  --repo ARG               : URL of subversion repository
                             ARG can contain {HOST} or a {host}
                             {HOST} is replaced by client hostname with domain
                             {host} is replaced by client hostname without domain
                             e.g. svn://192.168.3.5/servers/{host}/ygg
  --ro-username ARG        : specify a username ARG for read only
  --ro-password ARG        : specify a password ARG for read only

EOS
  end

  it 'should show help of debug (server)' do
    puts '---- should show help of debug (server)'
    out = catch_out{YggdrasilServer.command %w{help debug}}
    out.should == <<"EOS"
debug: launch TCP server by debug mode.
usage: #{File.basename($0)} debug

EOS
  end

  it 'should show help of daemon (server)' do
    puts '---- should show help of daemon (server)'
    out = catch_out{YggdrasilServer.command %w{help daemon}}
    out.should == <<"EOS"
daemon: launch TCP server by daemon mode.
usage: #{File.basename($0)} daemon

EOS
  end

  it 'should show help of results (server)' do
    puts '---- should show help of results'
    out = catch_out{YggdrasilServer.command %w{help results}}
    out.should == <<"EOS"
results: display the result of yggdrasil check command.
usage: #{File.basename($0)} results [OPTIONS...]

Valid options:
  --limit ARG              : minutes from the final report, to judge the host not be alive

EOS
  end
end
