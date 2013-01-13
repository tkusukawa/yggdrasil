require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "status" do
  it '-------- status' do
    puts '-------- status'
    prepare_environment
    init_yggdrasil

    # modify and not commit yet
    `echo HOGE >> /tmp/yggdrasil-test/A`
    `echo FOO >> /tmp/yggdrasil-test/B`
  end

  it 'should show status(absolute and relative)' do
    puts "---- should show status(absolute and relative)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command(%w{status /tmp/yggdrasil-test/A B --username hoge --password foo})
      end
    end
    out.should == <<"EOS"
M                3   tmp/yggdrasil-test/A
Status against revision:      3
M                3   tmp/yggdrasil-test/B
Status against revision:      3
EOS
  end

  it 'should show status (no path)' do
    puts "---- should show status (no path)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{status --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
M                3   tmp/yggdrasil-test/A
M                3   tmp/yggdrasil-test/B
Status against revision:      3
EOS
  end
end
