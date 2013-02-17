require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, 'log' do
  it '-------- log' do
    puts '-------- log'
    prepare_environment
    init_yggdrasil
  end

  it 'should show log (absolute path)' do
    puts '---- should show log (absolute path)'
    out = catch_out{Yggdrasil.command(%w{log /tmp} +
                                         %w{--username hoge --password foo})}
    out.gsub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r3 | hoge |  | 1 line

modify
------------------------------------------------------------------------
r2 | hoge |  | 1 line

add files
------------------------------------------------------------------------
EOS
  end

  it 'should show log (relative path)' do
    puts '---- should show log (relative path)'
    out = catch_out do
      FileUtils.cd '/tmp' do
        Yggdrasil.command %w{log yggdrasil-test}+
                          %w{--username hoge --password foo}
      end
    end
    out.gsub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r3 | hoge |  | 1 line

modify
------------------------------------------------------------------------
r2 | hoge |  | 1 line

add files
------------------------------------------------------------------------
EOS
  end

  it 'should show log (no path)' do
    puts '---- should show log (no path)'
    out = catch_out do
      FileUtils.cd '/tmp/yggdrasil-test' do
        Yggdrasil.command %w{log} +
                          %w{--username hoge --password foo}
      end
    end
    out.gsub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r3 | hoge |  | 1 line

modify
------------------------------------------------------------------------
r2 | hoge |  | 1 line

add files
------------------------------------------------------------------------
r1 | hoge |  | 1 line

yggdrasil init
------------------------------------------------------------------------
EOS
  end

  it 'should show log (with options)' do
    puts '---- should show log (with options)'
    out = catch_out{Yggdrasil.command(%w{log --revision 2 /tmp} +
                                         %w{--username hoge --password foo})}
    out.sub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<"EOS"
------------------------------------------------------------------------
r2 | hoge |  | 1 line

add files
------------------------------------------------------------------------
EOS
  end
end
