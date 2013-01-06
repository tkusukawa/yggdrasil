require File.dirname(__FILE__) + '/../lib/yggdrasil'

describe Yggdrasil, "commit" do
  before do
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo}
    Yggdrasil.command cmd_args
  end

  it 'should commit all' do
    Yggdrasil.command %w{add Gemfile /etc/fstab}
    cmd_args = ['commit', '--username', 'hoge', '--password', 'foo', '-m', 'COMMIT LOG']
#    $stdout = StringIO.new
    Yggdrasil.command cmd_args
    #$stdout.string.should == "hoge"
#    "abc".should == "abc"
  end
end
