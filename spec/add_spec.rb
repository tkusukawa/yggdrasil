require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "add" do
  before do
    puts '-------- before do (add)'
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    Yggdrasil.command %w{init} +
        %w{--username hoge --password foo} +
        %w{--repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/}
  end

  it 'should warn: add non-exist files' do
    puts '---- should warn: add non-exist files'
    out = catch_stdout{Yggdrasil.command %w{add hoge}}
    out.should == "no such file: #{`readlink -f hoge`}"

    out = catch_stdout{Yggdrasil.command %w{add /etc/hoge}}
    out.should == "no such file: /etc/hoge\n"
  end

  it 'should success: add exist files' do
    puts '---- should success: add exist files'
    Yggdrasil.command %w{add Gemfile /etc/fstab /etc/fstab}
    File.exist?("/tmp/yggdrasil-test/.yggdrasil/mirror#{`readlink -f Gemfile`.chomp}").should be_true
    File.exist?("/tmp/yggdrasil-test/.yggdrasil/mirror#{`readlink -f /etc/fstab`.chomp}").should be_true
  end
end
