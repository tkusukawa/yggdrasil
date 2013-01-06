require "open3"
require "yggdrasil/version"
require "yggdrasil/help"
require "yggdrasil/init"

class Yggdrasil

  def Yggdrasil.command(args)
    if args.size == 0
      Yggdrasil::help([])
      return
    end
    case args[0]
      when 'add'
        Yggdrasil.new.add(args[1..-1])
      when 'cleanup'
        Yggdrasil.new.cleanup(args[1..-1])
      when 'commit', 'ci'
        Yggdrasil.new.commit(args[1..-1])
      when 'diff', 'di'
        Yggdrasil.new.diff(args[1..-1])
      when 'help', 'h', '?'
        Yggdrasil::help(args[1..-1])
      when 'init'
        Yggdrasil::init(args[1..-1])
      when 'list', 'ls'
        Yggdrasil.new.list(args[1..-1])
      when 'log'
        Yggdrasil.new.log(args[1..-1])
      when 'status', 'stat', 'st'
        Yggdrasil.new.status(args[1..-1])
      when 'revert'
        Yggdrasil.new.revert(args[1..-1])
      when 'update'
        Yggdrasil.new.update(args[1..-1])
      when 'version', '--version'
        Yggdrasil::version
      else
        command_error "Unknown subcommand: '#{args[0]}'"
    end
  end

  # @param [String] msg
  def Yggdrasil.command_error(msg)
    puts "#{CMD} error: #{msg}"
    puts "Type '#{CMD} help' for usage."
    puts
    exit 1
  end

  # @param [String] cmd
  def Yggdrasil.exec_command(cmd)
    out,stat = Open3.capture2e cmd
    unless stat.success?
      puts "#{CMD} error: command failure: #{cmd}"
      puts
      exit stat.exitstatus
    end
    return out
  end

end


