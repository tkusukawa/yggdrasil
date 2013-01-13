require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "update" do
  it '-------- update' do
    puts '-------- update'
    prepare_environment
    init_yggdrasil
  end

  puts '-- make another working copy'
  `svn co file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name /tmp/yggdrasil-test/svn-work`

  puts '-- commit on another working copy'
  `echo hoge >> /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
  `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`

  it 'should success update (absolute path)' do
    puts '---- should success update (absolute path)'
    Yggdrasil.command %w{update /tmp/yggdrasil-test/A} +
                          %w{--username hoge --password foo}
  end

  puts '-- commit on another working copy'
  `echo hoge >> /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
  `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`

  it 'should success update (related path)' do
    puts '---- should success update (related path)'
    FileUtils.cd '/tmp/yggdrasil-test' do
      Yggdrasil.command %w{update A} +
                            %w{--username hoge --password foo}
    end
  end

  puts '-- commit on another working copy'
  `echo hoge >> /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`
  `svn commit -m 'another commit' /tmp/yggdrasil-test/svn-work/tmp/yggdrasil-test/A`

  it 'should success update (parent path)' do
    puts '---- should success update (related path)'
    Yggdrasil.command %w{update /tmp} +
                          %w{--username hoge --password foo}
  end
end
