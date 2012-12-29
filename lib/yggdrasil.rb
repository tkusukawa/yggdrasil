require "yggdrasil/version"
require "yggdrasil/help"

class Yggdrasil
  def Yggdrasil.command(args)
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
        puts "Unknown command: '#{args[0]}'"
        puts "Type '#{CMD} help' for usage."
    end
  end
end


