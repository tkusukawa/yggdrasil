require File.dirname(__FILE__) + '/spec_helper'
require 'yggdrasil_server'

describe Yggdrasil, 'init' do
  it '-------- init' do
    puts '-------- init'
    prepare_environment
  end

  it 'should error: "Not enough arguments provided"' do
    puts '---- should error: "Not enough arguments provided"'
    err = catch_err do
      lambda{Yggdrasil.command(%w{init --repo})}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: Not enough arguments provided: --repo\n\n"
  end

  it 'should error: can not access to SVN server' do
    puts '---- should error: can not access to SVN server'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    err = catch_err do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/hoge --username hoge --password foo}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: can not access to 'file:///tmp/yggdrasil-test/hoge'.\n\n"
  end

  it 'should error: need username' do
    puts '---- should error: need username'

    err = catch_err do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
          %w{--non-interactive}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    err.should == <<"EOS"
#{File.basename($0)} error: not exist directory(s) in repository: mng-repo/host-name

EOS
  end

  it 'should error: need password' do
    puts '---- should error: need password'

    err = catch_err do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
          %w{--non-interactive --parents --username hoge }
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    err.should ==
        "#{File.basename($0)} error: Can't get username or password\n\n"
  end

  it 'should error: no valid repository' do
    puts '---- should error: no valid repository'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`

    err = catch_err do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    err.should == "#{File.basename($0)} error: can not access to 'file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name'.\n\n"
  end

  it 'should success: create config file' do
    puts '---- should success: create config file'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`
    `svnadmin create /tmp/yggdrasil-test/svn-repo`

    Yggdrasil.command %w{init --debug} +
                          %w{--repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                          %w{--username hoge --password foo},
                      "Y\n"
  end

  it 'should success: create config file (private)' do
    puts '---- should success: create config file (private)'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`

    Yggdrasil.command %w{init --debug} +
                          %w{--repo private}

    File.exist?('/tmp/yggdrasil-test/.yggdrasil/config').should be_true
  end

  it 'should success: create config file (interactive)' do
    puts '---- should success: create config file (interactive)'
    `pkill svnserve`
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`
    `svnadmin create /tmp/yggdrasil-test/svn-repo`

    File.open('/tmp/yggdrasil-test/svn-repo/conf/passwd', 'w') do |f|
      f.write "[users]\nhoge = foo"
    end

    File.open('/tmp/yggdrasil-test/svn-repo/conf/svnserve.conf', 'w') do |f|
      f.write <<"EOS"
[general]
anon-access = none
auth-access = write
password-db = passwd
EOS
    end
    `svnserve -d`

    out = catch_out do
      Yggdrasil.command %w{init},
          "svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo/host-name/\n"\
          "hoge\n"\
          "foo\n"\
          "Y\n"
      end
    out.should == <<"EOS"
Input svn repo URL:#{' '}
check SVN access...
Input svn username:#{' '}
Input svn password:#{' '}
SVN access OK: svn://localhost/tmp/yggdrasil-test/svn-repo
not exist directory(s) in repository: mng-repo/host-name
make directory(s)? [Yn]:#{' '}
add svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo
add svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo/host-name
EOS
  end

  it 'should make checker example at init' do
    puts "\n---- should make checker example at init"
    dir = '/tmp/yggdrasil-test/.yggdrasil/checker'
    File.directory?(dir).should be_true

    example_checker = dir + '/gem_list'
    File.executable?(example_checker).should be_true
  end

  it 'should success init subcommand with server option' do
    puts '---- should success init subcommand with server option'
    prepare_environment

    YggdrasilServer.command %w{init} +
                          %w{--port 4000} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{host}/} +
                          %w{--ro-username hoge} +
                          %w{--ro-password foo}
    fork do
      YggdrasilServer.command %w{debug}
    end

    sleep 1
    Yggdrasil.command %w{init --debug --server localhost:4000},
                      "Y\nhoge\nfoo\n"

    File.exist?('/tmp/yggdrasil-test/.yggdrasil/config').should be_true
  end

  it 'should success init subcommand with server option AGAIN' do
    puts '---- should success init subcommand with server option AGAIN'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil/config`

    sleep 1
    Yggdrasil.command %w{init --debug --server localhost:4000}

    File.exist?('/tmp/yggdrasil-test/.yggdrasil/config').should be_true
  end

  it 'should alert and cancel: already exist config file' do
    puts '---- should alert and cancel: already exist config file'
    out = catch_out do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/hoge --username hoge --password foo}
      Yggdrasil.command cmd_args, "n\n"
    end
    out.should == <<"EOS"
Already exist config file: /tmp/yggdrasil-test/.yggdrasil/config
Overwrite? [Yn]:#{' '}
EOS
  end

  it 'should alert and overwrite: already exist config file' do
    puts '---- should alert and overwrite: already exist config file'
    out = catch_out do
      cmd_args = %w{init --repo private}
      Yggdrasil.command cmd_args, "Y\n"
    end
    out.should == <<"EOS"
Already exist config file: /tmp/yggdrasil-test/.yggdrasil/config
Overwrite? [Yn]:#{' '}
check SVN access...
SVN access OK: file:///tmp/yggdrasil-test/.yggdrasil/private_repo
EOS
    config = `cat /tmp/yggdrasil-test/.yggdrasil/config | grep repo=`
    config.should == <<"EOS"
repo=file:///tmp/yggdrasil-test/.yggdrasil/private_repo
EOS
  end

  it 'should error --non-interactive: already exist config file' do
    puts '---- should error --non-interactive: already exist config file'
    out = catch_out do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo}+
          %w{--username hoge --password foo} +
          %w{--non-interactive}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    out.should == <<"EOS"
Already exist config file: /tmp/yggdrasil-test/.yggdrasil/config
EOS
    config = `cat /tmp/yggdrasil-test/.yggdrasil/config | grep repo=`
    config.should == <<"EOS"
repo=file:///tmp/yggdrasil-test/.yggdrasil/private_repo
EOS
  end

  it 'should do --force: already exist config file' do
    puts '---- should do --force: already exist config file'
    out = catch_out do
      cmd_args = %w{init}+
          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/hoge/} +
          %w{--username hoge --password foo}+
          %w{--non-interactive --force}
      Yggdrasil.command cmd_args
    end
    out.should == <<"EOS"
check SVN access...
SVN access OK: svn://localhost/tmp/yggdrasil-test/svn-repo/servers
add svn://localhost/tmp/yggdrasil-test/svn-repo/servers/hoge
EOS
    config = `cat /tmp/yggdrasil-test/.yggdrasil/config | grep repo=`
    config.should == "repo=svn://localhost/tmp/yggdrasil-test/svn-repo/servers/hoge\n"
  end

  after(:all) do
    sock = TCPSocket.open('localhost', 4000)
    sock.puts('quit')
    sock.close
    Process.waitall
  end
end
