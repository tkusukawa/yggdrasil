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

  def Yggdrasil.parse_options(args, valid_params)
    options = Hash.new
    pos = 0
    while args.size > pos
      if valid_params.has_key?(args[pos])
        option_note = args[pos]
        option_key = valid_params[option_note]
        args = args[0...pos]+args[pos+1..-1]
        if option_key.to_s[-1] == '?'
          options[option_key] = true
        else
          unless args.size > pos
            command_error "Not enough arguments provided: #{option_note}"
          end
          option_value = args[pos]
          args = args[0...pos]+args[pos+1..-1]
          options[option_key] = option_value
        end
        next
      end
      pos += 1
    end
    return args, options
  end

end


