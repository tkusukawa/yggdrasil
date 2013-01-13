require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "add" do
  it '-------- add' do
    puts '-------- add'
    prepare_environment
    init_yggdrasil
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
