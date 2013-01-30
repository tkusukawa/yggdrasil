require File.dirname(__FILE__) + '/spec_helper'
require 'socket'

describe Yggdrasil, "server" do
  pid = 0
  before(:all) do
    puts '-------- server'
    prepare_environment
    Yggdrasil.command %w{init-server} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/} +
                          %w{--ro-username hoge} +
                          %w{--ro-password foo}
  end

  it "should make server" do
    puts "---- should make server"

    pid = fork do
      Yggdrasil.command %w{server}
      exit
    end
    pid.should_not be_nil
  end

  it "should alive" do
    puts "---- should make server"
    sleep 3
    res = Process.waitpid(pid,  Process::WNOHANG | Process::WUNTRACED)
    res.should be_nil
  end

  it "should response repository URL" do
    sock = TCPSocket.open("localhost", 4000)
    sock.write("get_repo")
    rcv = sock.gets
    rcv.should_not be_nil
    rcv.should == "svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}"
    sock.close
  end

  it do
    pending("under construction")
  end

  after(:all) do
    while (res = Process.waitpid(pid,  Process::WNOHANG | Process::WUNTRACED)).nil?
      Process.kill 9, pid
      sleep 1
    end
  end
end
