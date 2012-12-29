class Yggdrasil
  CMD= File::basename($0)

  global_options = <<"EOS"
Global options:
  --username ARG           : specify a username ARG
  --password ARG           : specify a password ARG
EOS

  def Yggdrasil.help(args)
    if args.size==0 then
      load "yggdrasil/help/summary.rb"
    else
      args.each do |subcommand|
        case subcommand
          when 'add'
            load "yggdrasil/help/add.rb"
          when 'cleanup'
            load "yggdrasil/help/cleanup.rb"
          when 'commit', 'ci'
            load "yggdrasil/help/commit.rb"
          when 'diff', 'di'
            load "yggdrasil/help/diff.rb"
          when 'help', '?', 'h'
            load "yggdrasil/help/help.rb"
          when 'init'
            load "yggdrasil/help/init.rb"
          when 'list', 'ls'
            load "yggdrasil/help/list.rb"
          when 'log'
            load "yggdrasil/help/log.rb"
          when 'status', 'stat', 'st'
            load "yggdrasil/help/status.rb"
          when 'revert'
            load "yggdrasil/help/revert.rb"
          when 'update'
            load "yggdrasil/help/update.rb"
          when 'version'
            load "yggdrasil/help/version.rb"
          else
            puts "\"#{subcommand}\": unknown subcommand."
        end
      end
    end
  end
end
