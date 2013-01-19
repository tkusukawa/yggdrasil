require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "init" do
  it '-------- init' do
    puts '-------- init'
    prepare_environment
  end

  it 'should error: "Not enough arguments provided"' do
    puts '---- should error: "Not enough arguments provided"'
    out = catch_out_err do
      lambda{Yggdrasil.command(%w{init --repo})}.should raise_error(SystemExit)
    end
    out.should == "#{File.basename($0)} error: Not enough arguments provided: --repo\n\n"
  end

  it 'should error: can not access to SVN server' do
    puts '---- should error: can not access to SVN server'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    out = catch_out_err do
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/hoge --username hoge --password foo}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
    out.should == "SVN access test...\nSVN error: can not access to 'file:///tmp/yggdrasil-test/hoge'.\n"
  end

  it 'should error: no valid repository' do
    puts '---- should error: no valid repository'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`

    catch_out_err do # > /dev/null
      cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo}
      lambda{Yggdrasil.command(cmd_args)}.should raise_error(SystemExit)
    end
  end

  it 'should success: create config file' do
    puts '---- should success: create config file'
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`
    `svnadmin create /tmp/yggdrasil-test/svn-repo`

    out = catch_out_err do
      Yggdrasil.command %w{init} +
          %w{--repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
          %w{--username hoge --password foo}
    end
    out.should == "SVN access test...\nSVN mkdir: OK.\n"
  end

  it 'should success: create config file (interactive)' do
    puts '---- should success: create config file (interactive)'
    `pkill svnserve`
    `rm -rf /tmp/yggdrasil-test/.yggdrasil`
    `rm -rf /tmp/yggdrasil-test/svn-repo`
    `svnadmin create /tmp/yggdrasil-test/svn-repo`

    File.open("/tmp/yggdrasil-test/svn-repo/conf/passwd", "w") do |f|
      f.write "[users]\nhoge = foo"
    end

    File.open("/tmp/yggdrasil-test/svn-repo/conf/svnserve.conf", "w") do |f|
      f.write <<"EOS"
[general]
anon-access = none
auth-access = write
password-db = passwd
EOS
    end
    `svnserve -d`

    out = catch_out_err do
      Yggdrasil.command %w{init},
          "svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo/host-name/\n"\
          "hoge\n"\
          "foo\n"
    end
    out.should == \
      "Input svn repo URL: "\
      "Input svn username: "\
      "Input svn password: "\
      "SVN access test...\n"\
      "SVN mkdir: OK.\n"
  end
end
