# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'
require 'yggdrasil_server'

describe YggdrasilServer, 'results' do
  before(:all) do
    puts '-------- results'
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
  end

  it 'should show nothing if no change' do
    Yggdrasil.command %w{init --debug --server localhost:4000} +
                          %w{--username hoge --password foo},
                      "Y\nhoge\nfoo\n"

    `echo hoge > /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/A}
    Yggdrasil.command %w{check}
    Yggdrasil.command %w{commit -m '1st' --username hoge --password foo /},
                      "Y\n"

    Yggdrasil.command %w{check}
    sleep 1
    out = catch_out do
      YggdrasilServer.command %w{results --expire 30 --debug}
    end
    out.should == ''
  end

  it 'should not show alert (there is result file, but there is no host in the repo)' do
    puts '---- should not show alert (there is result file, but there is no host in the repo)'

    `echo hoge > /tmp/yggdrasil-test/.yggdrasil/results/removed-host_192.168.1.30`
    sleep 1

    out = catch_out do
      YggdrasilServer.command %w{results --expire 30 --debug}
    end
    out.should == "Notice: delete result file (removed-host_192.168.1.30)\n\n"
  end

  it 'should show alert (there is no result, but it exist in the repo)' do
    puts '---- should show alert (there is no result, but it exist in the repo)'

    `rm -f /tmp/yggdrasil-test/.yggdrasil/results/*`

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results --expire 30 --debug})}.should raise_error(SystemExit)
    end
    out.should == <<"EOS"
######## No check result: #{Socket.gethostname}

EOS

  end

  it 'should show alert (difference)' do
    puts '---- should show alert (difference)'

    `echo foo >> /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{check --non-interactive}

    sleep 1

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results --expire 30 --debug})}.should raise_error(SystemExit)
    end
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"
######## Difference: #{Socket.gethostname}_127.0.0.1
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

  it 'should show alert (expired)' do
    puts '---- should show results'

    File.utime Time.local(2001, 5, 22, 23, 59, 59),
               Time.local(2001, 5, 1, 0, 0, 0),
               "/tmp/yggdrasil-test/.yggdrasil/results/#{Socket.gethostname}_127.0.0.1"
    sleep 1

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results --expire 30 --debug})}.should raise_error(SystemExit)
    end
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"
######## Expired: #{Socket.gethostname}_127.0.0.1 (2001-05-01 00:00:00 +0900)

EOS
  end

  it 'should show s-jis results' do
    puts '---- should show s-jis results'

    `rm /tmp/yggdrasil-test/.yggdrasil/results/*`
    `echo 'あいうえお' | nkf -s > /tmp/yggdrasil-test/.yggdrasil/results/#{Socket.gethostname}_127.0.0.1`

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results --debug})}.should raise_error(SystemExit)
    end
    out.should == <<"EOS"
######## Difference: #{Socket.gethostname}_127.0.0.1
あいうえお
EOS
  end


  after(:all) do
    sleep 1
    sock = TCPSocket.open('localhost', 4000)
    sock.puts('quit')
    sock.close
    Process.waitall
  end
end
