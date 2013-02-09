require File.dirname(__FILE__) + '/spec_helper'

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
    err.should ==
        "#{File.basename($0)} error: not exist directory(s): mng-repo/host-name\n\n"
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
    out.should == \
      'Input svn repo URL: '\
      "check SVN access...\n"\
      'Input svn username: '\
      "Input svn password: \n"\
      "SVN access OK: svn://localhost/tmp/yggdrasil-test/svn-repo\n"\
      "not exist directory(s): mng-repo/host-name\n"\
      'make directory(s)? [Yn]: '
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
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/servers/{HOST}/} +
                          %w{--ro-username hoge} +
                          %w{--ro-password foo}
    fork do
      YggdrasilServer.command %w{debug}
    end

    sleep 1
    Yggdrasil.command %w{init --debug --server localhost:4000},
                      "Y\nhoge\nfoo\n"

    File.exist?('/tmp/yggdrasil-test/.yggdrasil/config').should be_true

    sock = TCPSocket.open('localhost', 4000)
    sock.puts('quit')
    sock.close
    Process.waitall
  end
end
