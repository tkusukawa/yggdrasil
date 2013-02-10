require 'yggdrasil_server'

class YggdrasilServer

  # @param [Array] args
  def help(args)
    if args.size == 0
      puts <<EOS
usage: #@base_cmd <subcommand> [options] [args]
Yggdrasil version #{Yggdrasil::VERSION}
Type '#@base_cmd help <subcommand>' for help on a specific subcommand.

Available subcommands:
   daemon
   debug
   help (?, h)
   init
   results
   version

Yggdrasil server is a TCP server
to receive/record the yggdrasil check result of all managed servers.

At first, you should type '#@base_cmd init' to create config file.

EOS
    elsif args.size != 1 then
      error 'too many arguments.'
    else
      case args[0]
        when 'daemon'
          puts <<"EOS"
daemon: launch TCP server by daemon mode.
usage: #{File.basename($0)} daemon

EOS
        when 'debug'
          puts <<"EOS"
debug: launch TCP server by debug mode.
usage: #{File.basename($0)} debug

EOS
        when 'help', '?', 'h'
          puts <<"EOS"
help (?,h): Describe the usage of this program or its subcommands.
usage: #@base_cmd help [SUBCOMMAND]

EOS
        when 'init'
          puts <<"EOS"
init: setup yggdrasil server configuration.
usage: #@base_cmd init [OPTIONS...]

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
        when 'results'
          puts <<"EOS"
results: display the result of yggdrasil check command.
usage: #@base_cmd results [OPTIONS...]

Valid options:
  --expire ARG              : minutes from the final report, to judge the host not be alive

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
