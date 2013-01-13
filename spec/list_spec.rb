require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "list" do
  before do
    puts "-------- before do (list)"
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
    puts '-- create repo'
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    puts '-- ygg init'
    Yggdrasil.command %w{init} +
        %w{--repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
        %w{--username hoge --password foo}
    puts '-- add files'
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo  > /tmp/yggdrasil-test/B`
    Yggdrasil.command %w{add} +
        %w{/tmp/yggdrasil-test/A /tmp/yggdrasil-test/B}
    puts '-- commit'
    Yggdrasil.command %w{commit --non-interactive -m add\ files} +
        %w{--username hoge --password foo}
  end

  it 'should show list (absolute path)' do
    puts '---- should show list (absolute path)'
    out = catch_stdout{Yggdrasil.command(%w{list /tmp} +
                                         %w{--username hoge --password foo})}
    out.should == "yggdrasil-test/\n"
  end

  it 'should show list (relative path)' do
    puts '---- should show list (relative path)'
    out = catch_stdout do
      FileUtils.cd "/tmp" do
        Yggdrasil.command %w{list yggdrasil-test}+
                          %w{--username hoge --password foo}
      end
    end
    out.should == "A\nB\n"
  end

  it 'should show list (no path)' do
    puts '---- should show list (no path)'
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{list} +
                          %w{--username hoge --password foo}
      end
    end
    out.should == "A\nB\n"
  end

  it 'should show list (with options)' do
    puts '---- should show list (with options)'
    out = catch_stdout{Yggdrasil.command(%w{list --revision 2 --recursive --depth infinity /tmp} +
                                         %w{--username hoge --password foo})}
    out.should == "yggdrasil-test/\nyggdrasil-test/A\nyggdrasil-test/B\n"
  end
end
