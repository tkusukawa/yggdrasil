require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "log" do
  before do
    puts "-------- before do (log)"
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

  it 'should show log (absolute path)' do
    puts '---- should show log (absolute path)'
    out = catch_stdout{Yggdrasil.command(%w{log /tmp} +
                                         %w{--username hoge --password foo})}
    out.sub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r2 | hoge |  | 1 line
Changed paths:
   A /mng-repo/host-name/tmp
   A /mng-repo/host-name/tmp/yggdrasil-test
   A /mng-repo/host-name/tmp/yggdrasil-test/A
   A /mng-repo/host-name/tmp/yggdrasil-test/B

add files
------------------------------------------------------------------------
EOS
  end

  it 'should show log (relative path)' do
    puts '---- should show log (relative path)'
    out = catch_stdout do
      FileUtils.cd "/tmp" do
        Yggdrasil.command %w{log yggdrasil-test}+
                          %w{--username hoge --password foo}
      end
    end
    out.sub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r2 | hoge |  | 1 line
Changed paths:
   A /mng-repo/host-name/tmp
   A /mng-repo/host-name/tmp/yggdrasil-test
   A /mng-repo/host-name/tmp/yggdrasil-test/A
   A /mng-repo/host-name/tmp/yggdrasil-test/B

add files
------------------------------------------------------------------------
EOS
  end

  it 'should show log (no path)' do
    puts '---- should show log (no path)'
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{log} +
                          %w{--username hoge --password foo}
      end
    end
    out.sub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r2 | hoge |  | 1 line
Changed paths:
   A /mng-repo/host-name/tmp
   A /mng-repo/host-name/tmp/yggdrasil-test
   A /mng-repo/host-name/tmp/yggdrasil-test/A
   A /mng-repo/host-name/tmp/yggdrasil-test/B

add files
------------------------------------------------------------------------
EOS
  end

  it 'should show log (with options)' do
    puts '---- should show log (with options)'
    out = catch_stdout{Yggdrasil.command(%w{log --revision 2 /tmp} +
                                         %w{--username hoge --password foo})}
    out.sub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r2 | hoge |  | 1 line
Changed paths:
   A /mng-repo/host-name/tmp
   A /mng-repo/host-name/tmp/yggdrasil-test
   A /mng-repo/host-name/tmp/yggdrasil-test/A
   A /mng-repo/host-name/tmp/yggdrasil-test/B

add files
------------------------------------------------------------------------
EOS
  end
end
