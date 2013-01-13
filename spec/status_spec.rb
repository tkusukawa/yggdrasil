require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "status" do
  before do
    puts '-------- before do (status)'
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'

    # init
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    Yggdrasil.command %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                          %w{--username hoge --password foo}

    # add files and commit
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    FileUtils.cd "/tmp/yggdrasil-test" do
      Yggdrasil.command %w{add A B}
      Yggdrasil.command %w{commit --non-interactive --username hoge --password foo -m add\ A}
    end

    # modify A and commit
    `echo foo >> /tmp/yggdrasil-test/A`
    FileUtils.cd "/tmp/yggdrasil-test" do
      Yggdrasil.command %w{commit --non-interactive --username hoge --password foo -m modify\ A}
    end

    # modify and not commit yet
    `echo HOGE >> /tmp/yggdrasil-test/A`
    `echo FOO >> /tmp/yggdrasil-test/B`
  end

  it 'should show status' do
    puts "---- should success status"
    puts "-- absolute and relative"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command(%w{status /tmp/yggdrasil-test/A B --username hoge --password foo})
      end
    end
    out.should == <<"EOS"
M       tmp/yggdrasil-test/A
M       tmp/yggdrasil-test/B
EOS

    puts "-- no path"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{status --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
M       tmp/yggdrasil-test/A
M       tmp/yggdrasil-test/B
EOS

  end
end
