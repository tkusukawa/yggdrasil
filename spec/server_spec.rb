require File.dirname(__FILE__) + '/spec_helper'
require 'timeout'
require 'socket'
require 'yggdrasil_server'

describe YggdrasilServer, 'server' do

  before(:all) do
    puts '-------- server'
    prepare_environment
    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/} +
                          %w{--ro-username hoge} +
                          %w{--ro-password foo}
  end

  it 'should quit server on debug mode' do
    puts '---- should quit server on debug mode'

    fork do
      # client behavior
      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts('quit')
      sock.close
      exit
    end

    timeout 5 do
      YggdrasilServer.command %w{debug}
    end

    Process.waitall
  end

  it 'should response repository URL' do
    puts '---- should response repository URL'

    fork do
      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts('get_repo')
      rcv = sock.gets
      rcv.should_not be_nil
      rcv.chomp!
      rcv.should == 'svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}'
      sock.close

      sock = TCPSocket.open('localhost', 4000)
      sock.puts('quit')
      sock.close
      exit
    end

    timeout 5 do
      YggdrasilServer.command %w{debug}
    end

    Process.waitall
  end

  it 'should response get_ro_id_pw' do
    puts '---- should response get_ro_id_pw'

    fork do
      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts('get_ro_id_pw')
      username = sock.gets
      username.should_not be_nil
      username.chomp.should == 'hoge'

      password = sock.gets
      password.should_not be_nil
      password.chomp.should == 'foo'
      sock.close

      sock = TCPSocket.open('localhost', 4000)
      sock.puts('quit')
      sock.close
      exit
    end

    timeout 5 do
      YggdrasilServer.command %w{debug}
    end

    Process.waitall
  end

  it 'should write file of check result to results directory' do
    puts '---- should write file of check result to results directory'

    fork do
      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts('put_result HOSTNAME')
      sock.puts <<"EOS"
CHECK RESULTS................1
CHECK RESULTS................2
EOS
      sock.close

      sock = TCPSocket.open('localhost', 4000)
      sock.puts('quit')
      sock.close
      exit
    end

    timeout 5 do
      YggdrasilServer.command %w{debug}
    end

    File.exist?('/tmp/yggdrasil-test/.yggdrasil/results/HOSTNAME_127.0.0.1').should be_true
    `cat /tmp/yggdrasil-test/.yggdrasil/results/HOSTNAME_127.0.0.1`.should == <<"EOS"
CHECK RESULTS................1
CHECK RESULTS................2
EOS

    Process.waitall
  end

  it 'should not response get_ro_id_pw' do
    puts '---- should not response get_ro_id_pw'
    prepare_environment
    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/},
                      "\n\n"

    fork do
      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts("\n")
      no_res = sock.gets
      no_res.should be_nil
      sock.close

      sleep 1
      sock = TCPSocket.open('localhost', 4000)
      sock.puts('get_ro_id_pw')
      username = sock.gets
      username.should be_nil
      sock.close

      sock = TCPSocket.open('localhost', 4000)
      sock.puts('quit')
      sock.close
      exit
    end

    timeout 5 do
      YggdrasilServer.command %w{debug}
    end

    Process.waitall
  end
end
