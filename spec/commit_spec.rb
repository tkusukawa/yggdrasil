require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "commit" do
  before do
    puts '-------- before do (commit)'
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    cmd_args = %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/ --username hoge --password foo}
    Yggdrasil.command cmd_args
  end

  it 'should commit added file' do
    puts '---- should commit added file'
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    FileUtils.cd "/tmp/yggdrasil-test" do
      puts '-- add'
      Yggdrasil.command %w{add A /tmp/yggdrasil-test/B}
    end

    puts "-- commit"
    Yggdrasil.command %w{commit --username hoge --password foo},
                      "0\nY\nadd A and B\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/A'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/A`
    puts res
    res.should == "hoge\n"

    puts "---- should commit modified file"
    puts "-- modify"
    `echo hoge >> /tmp/yggdrasil-test/A`

    puts "-- commit"
    Yggdrasil.command %w{commit --username hoge --password foo},
                      "0\nY\nmodify A\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/A'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/A`
    puts res
    res.should == "hoge\nhoge\n"


    puts "---- should commit specified file only"
    `echo A >> /tmp/yggdrasil-test/A`
    `echo B >> /tmp/yggdrasil-test/B`

    Yggdrasil.command %w{commit --username hoge},
                      "foo\nn\n"
    Yggdrasil.command %w{commit --username hoge --password foo -m modify /tmp/yggdrasil-test/B},
                      "0\nY\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/B'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/B`
    puts res
    res.should == "foo\nB\n"


    puts "---- should not commit deleted file"
    `rm -f /tmp/yggdrasil-test/A`

    Yggdrasil.command %w{commit --username hoge --password foo -m delete},
                      "0\nn\n"

    puts "---- should commit deleted file"
    `echo hoge > /tmp/yggdrasil-test/A`
    `rm -f /tmp/yggdrasil-test/B`

    Yggdrasil.command %w{commit --username hoge --password foo -m delete},
                      "0\n1\nY\n"

    puts "\n-- check committed delete file"
    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\n"
  end
end
