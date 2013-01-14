require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "status" do
  it '-------- status' do
    puts '-------- status'
    prepare_environment
    init_yggdrasil

    # modify and not commit yet
    `echo HOGE >> /tmp/yggdrasil-test/A`
    `rm -f /tmp/yggdrasil-test/B`
    `mkdir /tmp/yggdrasil-test/c`
    `echo bar > /tmp/yggdrasil-test/c/C`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/c/C}
  end

  it 'should show status(absolute and relative)' do
    puts "---- should show status(absolute and relative)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{status /tmp/yggdrasil-test/A B --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
M                3   tmp/yggdrasil-test/A
D                3   tmp/yggdrasil-test/B
EOS
  end

  it 'should show status(/)' do
    puts "---- should show status(/)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{status / --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
M                3   tmp/yggdrasil-test/A
D                3   tmp/yggdrasil-test/B
A                0   tmp/yggdrasil-test/c/C
A                0   tmp/yggdrasil-test/c
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
D                3   tmp/yggdrasil-test/B
A                0   tmp/yggdrasil-test/c/C
A                0   tmp/yggdrasil-test/c
EOS
  end
end
