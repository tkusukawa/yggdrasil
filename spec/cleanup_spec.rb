require File.dirname(__FILE__) + '/../lib/yggdrasil'

describe Yggdrasil, "cleanup" do
  before do
    puts '-------- before do (cleanup)'
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'

    # init
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    Yggdrasil.command %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                      %w{--username hoge --password foo}

    # add A,B
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    FileUtils.cd "/tmp/yggdrasil-test" do
      Yggdrasil.command %w{add A /tmp/yggdrasil-test/B}
    end

    # commit
    Yggdrasil.command %w{commit --non-interactive --username hoge --password foo -m add\ A\ and\ B}

  end

  it 'should success cleanup' do
    puts "---- should success cleanup"
    puts "-- rm .svn"
    `rm -rf /tmp/yggdrasil-test/.yggdrasil/mirror/.svn`

    puts "-- cleanup"
    Yggdrasil.command %w{cleanup --username hoge --password foo}

    puts "-- check .svn"
    res = File.exist?("/tmp/yggdrasil-test/.yggdrasil/mirror/.svn")
    p res
    res.should == true
  end
end
