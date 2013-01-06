require File.dirname(__FILE__) + '/../lib/yggdrasil'

describe Yggdrasil, "init" do
  before do
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
  end

  it 'should error: "Not enough arguments provided"' do
    $stdout = StringIO.new
    lambda{Yggdrasil.command(%w{init --repo})}.should raise_error(SystemExit)
    $stdout.string.should == <<"EOS"
#{File.basename($0)} error: Not enough arguments provided: --repo
Type '#{File.basename($0)} help' for usage.

EOS
  end

  it 'should error: can not access to SVN server' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    $stdout = StringIO.new
    cmd = 'init --repo file:///tmp/yggdrasil-test/hoge --username hoge --password foo'
    lambda{Yggdrasil.command(cmd.split)}.should raise_error(SystemExit)
    $stdout.string.should == "SVN access test...\nSVN error: can not access to 'file:///tmp/yggdrasil-test/hoge'.\n"
  end

  it 'should error: no valid repository' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`

    $stdout = StringIO.new
    cmd = 'init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo'
    lambda{Yggdrasil.command(cmd.split)}.should raise_error(SystemExit)
  end

  it 'should success: create config file' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`
    `svnadmin create /tmp/yggdrasil-test/svn-repo`

    $stdout = StringIO.new
    cmd = 'init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo'
    Yggdrasil.command cmd.split
    $stdout.string.should == "SVN access test...\nSVN mkdir: OK.\n"
  end

  after do
    # `rm -rf /tmp/yggdrasil-test`
  end

end
