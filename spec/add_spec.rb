require File.dirname(__FILE__) + '/../lib/yggdrasil'

describe Yggdrasil, "add" do
  before do
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo}
    Yggdrasil.command cmd_args
  end

  it 'should warn: add non-exist files' do
    $stdout = StringIO.new
    Yggdrasil.command %w{add hoge}
    $stdout.string.should == "no such file: #{`readlink -f hoge`}"

    $stdout = StringIO.new
    Yggdrasil.command %w{add /etc/hoge}
    $stdout.string.should == "no such file: /etc/hoge\n"
  end

  it 'should success: add exist files' do
    Yggdrasil.command %w{add Gemfile /etc/fstab /etc/fstab}
    File.exist?("/tmp/yggdrasil-test/.yggdrasil/mirror#{`readlink -f Gemfile`.chomp}").should be_true
    File.exist?("/tmp/yggdrasil-test/.yggdrasil/mirror#{`readlink -f /etc/fstab`.chomp}").should be_true
  end

end
