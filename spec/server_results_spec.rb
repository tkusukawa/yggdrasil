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
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/gem_list`

    `echo hoge > /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/A}
    Yggdrasil.command %w{check}
    Yggdrasil.command %w{commit -m '1st' --username hoge --password foo /},
                      "Y\n"

    Yggdrasil.command %w{check}
    sleep 1
    out = catch_out do
      YggdrasilServer.command %w{results --expire 30}
    end
    out.should == ''
  end

  it 'should show results' do
    puts '---- should show results'

    `echo foo >> /tmp/yggdrasil-test/A`
    Yggdrasil.command %w{check --non-interactive}

    `echo hoge > /tmp/yggdrasil-test/.yggdrasil/results/hoge-old`
    File.utime Time.local(2001, 5, 22, 23, 59, 59),
               Time.local(2001, 5, 1, 0, 0, 0),
               '/tmp/yggdrasil-test/.yggdrasil/results/hoge-old'
    sleep 1

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results --expire 30})}.should raise_error(SystemExit)
    end
    out.gsub! /[ ]+/, ' '
    out.should == <<"EOS"
######## hoge-old: last check is too old: 2001-05-01 00:00:00 +0900

######## #{Socket.gethostname}_127.0.0.1 Mismatch:
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

  it 'should show s-jis results' do
    puts '---- should show s-jis results'

    `rm /tmp/yggdrasil-test/.yggdrasil/results/*`
    `echo 'あいうえお' | nkf -s > /tmp/yggdrasil-test/.yggdrasil/results/hoge`

    out = catch_out do
      lambda{YggdrasilServer.command(%w{results})}.should raise_error(SystemExit)
    end
    out.should == <<"EOS"
######## hoge Mismatch:
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
