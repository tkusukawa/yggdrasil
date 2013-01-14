require File.dirname(__FILE__) + '/../lib/yggdrasil'

def prepare_environment
  puts "---- prepare environment"

  `pkill svnserve`
  `rm -rf /tmp/yggdrasil-test`
  Dir.mkdir('/tmp/yggdrasil-test', 0755)
  ENV['HOME']='/tmp/yggdrasil-test'

  puts '-- create repo'
  `svnadmin create /tmp/yggdrasil-test/svn-repo`

  puts '-- launch svnserve'
  Yggdrasil.system3 'cat > /tmp/yggdrasil-test/svn-repo/conf/passwd', true, "[users]\nhoge = foo"
  Yggdrasil.system3 'cat > /tmp/yggdrasil-test/svn-repo/conf/svnserve.conf', true, <<"EOS"
[general]
anon-access = none
auth-access = write
password-db = passwd
EOS
  `svnserve -d`
end

def init_yggdrasil
  puts '---- init yggdrasil and some commits'
  puts '-- init'
  Yggdrasil.command %w{init} +
                    %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                    %w{--username hoge --password foo}
  puts '-- add'
  `echo hoge > /tmp/yggdrasil-test/A`
  `echo foo  > /tmp/yggdrasil-test/B`
  Yggdrasil.command %w{add} +
                    %w{/tmp/yggdrasil-test/A /tmp/yggdrasil-test/B}
  puts '-- commit'
  Yggdrasil.command %w{commit / --non-interactive -m add\ files} +
                    %w{--username hoge --password foo}
  puts '-- modify'
  `echo hoge >> /tmp/yggdrasil-test/A`
  `echo foo  >> /tmp/yggdrasil-test/B`
  puts '-- commit'
  Yggdrasil.command %w{commit / --non-interactive -m modify} +
                    %w{--username hoge --password foo}
end

def catch_stdout
  exit 1 unless block_given?
  tmp_out = $stdout
  $stdout = StringIO.new
  yield
  $stdout,tmp_out = tmp_out, $stdout
  tmp_out.string
end
