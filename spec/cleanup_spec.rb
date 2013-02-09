require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, 'cleanup' do
  it '-------- cleanup' do
    puts '-------- cleanup'
    prepare_environment
    init_yggdrasil
  end

  it 'should success cleanup' do
    puts '---- should success cleanup'
    puts '-- rm .svn'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil/mirror/.svn`

    puts '-- cleanup'
    Yggdrasil.command %w{cleanup --username hoge --password foo}

    puts '-- check .svn'
    res = File.exist?('/tmp/yggdrasil-test/.yggdrasil/mirror/.svn')
    p res
    res.should == true
  end
end
