require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "update" do
  it '-------- update' do
    puts '-------- update'
    prepare_environment
    init_yggdrasil

    puts '-- make another working copy'
    puts `svn co file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name /tmp/yggdrasil-test/svn-work`
  end

  it 'should success update (related/absolute path)' do
    puts '---- should success update (related/absolute path)'
    puts '-- commit on another working copy'
    `echo A:related/absolute path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
    `echo B:related/absolute path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/B`
    `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/`

    FileUtils.cd '/tmp/yggdrasil-test' do
      Yggdrasil.command %w{update A /tmp/yggdrasil-test/B} +
                            %w{--username hoge --password foo},
                        "0\nY\n"
    end
    `cat /tmp/yggdrasil-test/A`.should == "A:related/absolute path\n"
    `cat /tmp/yggdrasil-test/B`.should == "B:related/absolute path\n"
  end

  it 'should success update (only one file)' do
    puts '---- should success update (only one file)'

    puts '-- commit on another working copy'
    `echo A:only one file > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
    `echo B:only one file > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/B`
    `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test`

    Yggdrasil.command %w{update /tmp/yggdrasil-test/A} +
                          %w{--username hoge --password foo --non-interactive}

    `cat /tmp/yggdrasil-test/A`.should == "A:only one file\n"
    `cat /tmp/yggdrasil-test/B`.should == "B:related/absolute path\n"
  end

  it 'should success update (parent path)' do
    puts '---- should success update (parent path)'
    puts '-- commit on another working copy'
    `echo A:parent path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
    `echo B:parent path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/B`
    `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test`

    Yggdrasil.command %w{update /tmp} +
                          %w{--username hoge --password foo},
                      "1\nY\n"
    `cat /tmp/yggdrasil-test/A`.should == "A:parent path\n"
    `cat /tmp/yggdrasil-test/B`.should == "B:parent path\n"
  end

  it 'should success update (no path)' do
    puts '---- should success update (no path)'
    puts '-- commit on another working copy'
    `echo A:no path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
    `echo B:no path > /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/B`
    `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test`

    FileUtils.cd '/tmp' do
      Yggdrasil.command %w{update} +
                            %w{--username hoge --password foo --non-interactive}
    end
    `cat /tmp/yggdrasil-test/A`.should == "A:no path\n"
    `cat /tmp/yggdrasil-test/B`.should == "B:no path\n"
  end
end
