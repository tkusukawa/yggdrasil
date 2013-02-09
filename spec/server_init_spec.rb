require File.dirname(__FILE__) + '/spec_helper'
require 'yggdrasil_server'

describe YggdrasilServer, 'init (server)' do
  it '-------- init (server)' do
    puts '-------- init (server)'
    prepare_environment
  end

  it 'should error: "Not enough arguments provided"' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    puts '---- should error: "Not enough arguments provided"'
    err = catch_err do
      lambda{YggdrasilServer.command(%w{init --repo})}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: Not enough arguments provided: --repo\n\n"
  end

  it 'should make server_config (all interactive)' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    puts '---- should make server_config (all interactive)"'
    YggdrasilServer.command %w{init},
                      "4000\n"+ # tcp port
                      "svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/\n"+ #svn repository
                      "hoge\n"+ # read only username
                      "foo\n" #read only password

    File.exists?('/tmp/yggdrasil-test/.yggdrasil/server_config').should be_true
    `cat /tmp/yggdrasil-test/.yggdrasil/server_config`.should == <<"EOS"
port=4000
repo=svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}
ro_username=hoge
ro_password=foo
EOS
  end

  it 'should make server_config (all argument)' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    puts '---- should make server_config (all interactive)"'
    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/} +
                          %w{--ro-username hoge} +
                          %w{--ro-password foo}

    File.exists?('/tmp/yggdrasil-test/.yggdrasil/server_config').should be_true
    `cat /tmp/yggdrasil-test/.yggdrasil/server_config`.should == <<"EOS"
port=4000
repo=svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}
ro_username=hoge
ro_password=foo
EOS
  end

  it 'should make server_config (no ro-username)' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    puts '---- should make server_config (all interactive)"'
    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/},
                      "\n" # prompt for input read only username

    File.exists?('/tmp/yggdrasil-test/.yggdrasil/server_config').should be_true
    `cat /tmp/yggdrasil-test/.yggdrasil/server_config`.should == <<"EOS"
port=4000
repo=svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}
EOS
  end

  it 'should error if argument have only password' do
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    puts '---- should error if argument have only password'

    err = catch_err do
      args = %w{init} +
          %w{--port 4000} +
          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/} +
          %w{--ro-password foo}
      lambda{YggdrasilServer.command(args)}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: --ro-password option need --ro-username, too.\n\n"
  end
end