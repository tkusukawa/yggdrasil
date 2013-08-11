require File.dirname(__FILE__) + '/spec_helper'
require 'yggdrasil_server'

describe Yggdrasil, 'check' do
  before(:all) do
    puts '-------- check'
    prepare_environment
    init_yggdrasil
    `rm -f /tmp/yggdrasil-test/A`
    `echo foo >> /tmp/yggdrasil-test/B`
    `echo bar > /tmp/yggdrasil-test/C`
    Yggdrasil.command(%w{add /tmp/yggdrasil-test/C})
  end

  it 'should display check result by "check"' do
    cmd = %w{check --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/C
1:D tmp/yggdrasil-test/A
2:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS
  end

  it 'should display check result by "c"' do
    cmd = %w{c --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/C
1:D tmp/yggdrasil-test/A
2:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS
  end

  it 'should display check result by "status"' do
    cmd = %w{status --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/C
1:D tmp/yggdrasil-test/A
2:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS
  end

  it 'should display check result by "stat"' do
    cmd = %w{stat --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/C
1:D tmp/yggdrasil-test/A
2:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS
  end

  it 'should display check result by "st"' do
    cmd = %w{st --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/C
1:D tmp/yggdrasil-test/A
2:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS

    `echo hoge > /tmp/yggdrasil-test/A`
    `echo hoge >> /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    `echo foo >> /tmp/yggdrasil-test/B`
    `rm -f /tmp/yggdrasil-test/C`
  end

  it 'should fail by spell miss of path' do
    cmd = %w{st --username hoge --password foo /hoge}
    err = catch_err do
      lambda{Yggdrasil.command(cmd)}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: no such file of directory:/hoge\n\n"
  end

  it 'should fail by spell miss of option' do
    cmd = %w{st --username hoge --password foo --hoge}
    err = catch_err do
      lambda{Yggdrasil.command(cmd)}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: invalid options: --hoge\n\n"
  end

  it 'should execute checker and svn add the result' do
    puts "\n---- should execute checker and svn add the result"
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/gem_list`
    `echo 'echo hoge' > /tmp/yggdrasil-test/.yggdrasil/checker/hoge`
    `chmod +x /tmp/yggdrasil-test/.yggdrasil/checker/hoge`

    cmd = %w{check --username hoge --password foo --non-interactive}
    out = catch_out {Yggdrasil.command(cmd, "Y\n")}
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"
10 files checked.
A 0 tmp/yggdrasil-test/.yggdrasil
A 0 tmp/yggdrasil-test/.yggdrasil/checker
A 0 tmp/yggdrasil-test/.yggdrasil/checker/hoge
A 0 tmp/yggdrasil-test/.yggdrasil/checker_result
A 0 tmp/yggdrasil-test/.yggdrasil/checker_result/hoge

Index: tmp/yggdrasil-test/.yggdrasil/checker/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker/hoge	(revision 0)
+++ tmp/yggdrasil-test/.yggdrasil/checker/hoge	(revision 0)
@@ -0,0 +1 @@
+echo hoge

Property changes on: tmp/yggdrasil-test/.yggdrasil/checker/hoge
___________________________________________________________________
Added: svn:executable
 + *


Index: tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 0)
+++ tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 0)
@@ -0,0 +1 @@
+hoge

Yggdrasil check: NG!!!
EOS
  end

  it 'should commit the checker result' do
    puts "\n---- should commit the checker result"
    cmd = %w{commit / --username hoge --password foo --non-interactive -m add\ checker}
    out = catch_out {Yggdrasil.command cmd}

    out.should == <<"EOS"
Adding         tmp/yggdrasil-test/.yggdrasil
Adding         tmp/yggdrasil-test/.yggdrasil/checker
Adding         tmp/yggdrasil-test/.yggdrasil/checker/hoge
Adding         tmp/yggdrasil-test/.yggdrasil/checker_result
Adding         tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
Transmitting file data ..
Committed revision 4.
EOS
  end

  it 'should delete result if checker deleted' do
    puts "\n---- should delete result if checker deleted"
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/hoge`
    cmd = %w{check --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "A\n")}
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"

0:D tmp/yggdrasil-test/.yggdrasil/checker/hoge
1:D tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
OK? [A|q|<num to diff>]:#{' '}
9 files checked.
D 4 tmp/yggdrasil-test/.yggdrasil/checker/hoge
D 4 tmp/yggdrasil-test/.yggdrasil/checker_result/hoge

Index: tmp/yggdrasil-test/.yggdrasil/checker/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker/hoge	(revision 4)
+++ tmp/yggdrasil-test/.yggdrasil/checker/hoge	(working copy)
@@ -1 +0,0 @@
-echo hoge

Index: tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 4)
+++ tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(working copy)
@@ -1 +0,0 @@
-hoge

Yggdrasil check: NG!!!
EOS
  end

  it 'should commit the checker result(delete)' do
    puts "\n---- should commit the checker result(delete)"
    cmd = %w{commit / --username hoge --password foo --non-interactive -m delete\ checker}
    out = catch_out {Yggdrasil.command cmd}

    out.should == <<"EOS"
Deleting       tmp/yggdrasil-test/.yggdrasil/checker/hoge
Deleting       tmp/yggdrasil-test/.yggdrasil/checker_result/hoge

Committed revision 5.
EOS
  end

  it 'should record check result by yggdrasil server (add)' do
    puts "\n---- should record check result by yggdrasil server (add)"

    prepare_environment

    sock = 0
    begin
      sock = TCPSocket.open('localhost', 4000)
    rescue
      puts 'OK. no server'
    else
      puts 'NG. zombie server. try quit'
      sock.puts('quit')
      sock.close
    end

    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/}+
                          %w{--ro-username hoge --ro-password foo},
                      "\n\n"
    fork do
      YggdrasilServer.command %w{debug}
    end

    sleep 1
    Yggdrasil.command %w{init --debug --server localhost:4000} +
                          %w{--username hoge --password foo},
                      "Y\nhoge\nfoo\n"

    Yggdrasil.command %w{check --non-interactive}

    sleep 2
    File.exist?('/tmp/yggdrasil-test/.yggdrasil/results').should be_true
    files = Dir.entries('/tmp/yggdrasil-test/.yggdrasil/results')
    result_files = files.select{|file| %r{^#{Socket.gethostname}} =~ file}
    result_files.size.should == 1
    out = `cat /tmp/yggdrasil-test/.yggdrasil/results/#{result_files[0]}`
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"

EOS
  end

  it 'should record check result by yggdrasil server (modify)' do
    puts "\n---- should record check result by yggdrasil server (modify)"

    `echo hoge > /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/A}
    Yggdrasil.command %w{commit --username hoge --password foo /},
                      "Y\nHOGE\n"

    `echo foo >> /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{check}, "A\n"

    sleep 1
    files = Dir.entries('/tmp/yggdrasil-test/.yggdrasil/results')
    result_files = files.select{|file| %r{^#{Socket.gethostname}} =~ file}
    out = `cat /tmp/yggdrasil-test/.yggdrasil/results/#{result_files[0]}`
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"
M 2 tmp/yggdrasil-test/A

Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 2)
+++ tmp/yggdrasil-test/A	(working copy)
@@ -1 +1,2 @@
 hoge
+foo

EOS
  end

  it 'should record check result by yggdrasil server (OK)' do
    puts "\n---- should record check result by yggdrasil server (OK)"

    Yggdrasil.command %w{commit --username hoge --password foo} +
                          %w{-m HOGE --non-interactive}

    Yggdrasil.command %w{check --non-interactive}

    sleep 1
    files = Dir.entries('/tmp/yggdrasil-test/.yggdrasil/results')
    result_files = files.select{|file| %r{^#{Socket.gethostname}} =~ file}
    `cat /tmp/yggdrasil-test/.yggdrasil/results/#{result_files[0]}`.should == "\n"
  end

  it 'should recover delete flag' do
    pending "under construction..."
    puts "\n---- should recover delete flag"

    `mkdir /tmp/yggdrasil-test/c`
    `echo bar > /tmp/yggdrasil-test/c/C`

    Yggdrasil.command %w{add /tmp/yggdrasil-test/c/C}
    Yggdrasil.command %w{commit --username hoge --password foo} +
                          %w{-m BAR --non-interactive}

    `mv /tmp/yggdrasil-test/c /tmp/yggdrasil-test/cc`
    cmd = %w{c --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

0:D tmp/yggdrasil-test/c
1:D tmp/yggdrasil-test/c/C
OK? [A|q|<num to diff>]:#{' '}
EOS

    `mv /tmp/yggdrasil-test/cc /tmp/yggdrasil-test/c`
    cmd = %w{c --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd, "q\n")}
    out.should == <<"EOS"

EOS
  end

  after(:all) do
    sock = TCPSocket.open('localhost', 4000)
    sock.puts('quit')
    sock.close
    Process.waitall
  end
end
