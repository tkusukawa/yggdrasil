require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "results" do
  before(:all) do
    puts '-------- results'
    prepare_environment

    sock = 0
    begin
      sock = TCPSocket.open("localhost", 4000)
    rescue
      puts "OK. no server"
    else
      puts "NG. zombie server. try quit"
      sock.puts("quit")
      sock.close
    end

    Yggdrasil.command %w{init-server} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/}+
                          %w{--ro-username hoge --ro-password foo},
                      "\n\n"
    fork do
      Yggdrasil.command %w{server --debug}
    end
    sleep 1
    Yggdrasil.command %w{init --debug --server localhost:4000} +
                          %w{--username hoge --password foo},
                      "Y\nhoge\nfoo\n"
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/gem_list`
    Yggdrasil.command %w{check}
    sleep 1
  end

  it 'should show results' do
    puts '---- should show results'

    `echo hoge > /tmp/yggdrasil-test/.yggdrasil/results/hoge-old`
    File.utime Time.local(2001, 5, 22, 23, 59, 59),
               Time.local(2001, 5, 1, 0, 0, 0),
               "/tmp/yggdrasil-test/.yggdrasil/results/hoge-old"

    out = catch_out do
      Yggdrasil.command %w{results --limit 30}
    end

    out.should == <<"EOS"
######## hoge-old TOO OLD: 2001-05-01 00:00:00 +0900
######## centos6_127.0.0.1 Mismatch:
A                0   tmp/yggdrasil-test
A                0   tmp/yggdrasil-test/.yggdrasil
A                0   tmp/yggdrasil-test/.yggdrasil/checker_result
A                0   tmp

EOS
  end

  after(:all) do
    sleep 1
    sock = TCPSocket.open("localhost", 4000)
    sock.puts("quit")
    sock.close
    Process.waitall
  end
end
