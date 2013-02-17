require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, 'list' do
  it '-------- list' do
    puts '-------- list'
    prepare_environment
    init_yggdrasil
  end

  it 'should show list (absolute path)' do
    puts '---- should show list (absolute path)'
    out = catch_out{Yggdrasil.command(%w{list /tmp} +
                                         %w{--username hoge --password foo})}
    out.should == "yggdrasil-test/\n"
  end

  it 'should show list (relative path)' do
    puts '---- should show list (relative path)'
    out = catch_out do
      FileUtils.cd '/tmp' do
        Yggdrasil.command %w{list yggdrasil-test}+
                          %w{--username hoge --password foo}
      end
    end
    out.should == ".yggdrasil/\nA\nB\n"
  end

  it 'should show list (no path)' do
    puts '---- should show list (no path)'
    out = catch_out do
      FileUtils.cd '/tmp/yggdrasil-test' do
        Yggdrasil.command %w{list} +
                          %w{--username hoge --password foo}
      end
    end
    out.should == <<"EOS"
tmp/
tmp/yggdrasil-test/
tmp/yggdrasil-test/.yggdrasil/
tmp/yggdrasil-test/.yggdrasil/checker_result/
tmp/yggdrasil-test/A
tmp/yggdrasil-test/B
EOS
  end

  it 'should show list with options (1)' do
    puts '---- should show list with options (1)'
    out = catch_out{Yggdrasil.command(%w{list -R --revision 2 /tmp} +
                                          %w{--username hoge --password foo})}
    out.should == <<"EOS"
yggdrasil-test/
yggdrasil-test/.yggdrasil/
yggdrasil-test/.yggdrasil/checker_result/
yggdrasil-test/A
yggdrasil-test/B
EOS
  end

  it 'should show list with options (2)' do
    puts '---- should show list with options (2)'
    out = catch_out{Yggdrasil.command(%w{list --revision 2 --recursive /tmp} +
                                          %w{--username hoge --password foo})}
    out.should == <<"EOS"
yggdrasil-test/
yggdrasil-test/.yggdrasil/
yggdrasil-test/.yggdrasil/checker_result/
yggdrasil-test/A
yggdrasil-test/B
EOS
  end
end
