require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "results" do
  before(:all) do
    puts '-------- results'
    prepare_environment
    Yggdrasil.command %w{init-server} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/},
                      "\n\n"
    fork do
      Yggdrasil.command %w{server --debug}
    end

  end

  it do
    pending("under construction")
  end

  after(:all) do
    sleep 1
    sock = TCPSocket.open("localhost", 4000)
    sock.puts("quit")
    sock.close
    Process.waitall
  end
end
