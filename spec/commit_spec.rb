require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, 'commit' do
  it '-------- commit' do
    puts '-------- commit'
    prepare_environment

    puts '-- init'
    Yggdrasil.command %w{init} +
                          %w{--repo svn://localhost/tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                          %w{--username hoge --password foo --parents}
  end

  it 'should commit added files' do
    puts '---- should commit added files'
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    FileUtils.cd '/tmp/yggdrasil-test' do
      puts '-- add'
      Yggdrasil.command %w{add A /tmp/yggdrasil-test/B}
    end

    puts '-- commit'
    FileUtils.cd '/tmp/yggdrasil-test' do
      Yggdrasil.command %w{commit --username hoge --password foo A B},
                        "0\nY\nadd A and B\n"
    end

    puts "\n-- check committed file 'tmp/yggdrasil-test/A'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/A`
    puts res
    res.should == "hoge\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/B'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/B`
    puts res
    res.should == "foo\n"
  end

  it 'should commit modified file' do
    puts '---- should commit modified file'
    puts '-- modify'
    `echo hoge >> /tmp/yggdrasil-test/A`

    puts '-- commit'
    Yggdrasil.command %w{commit / --username hoge --password foo},
                      "0\nY\nmodify A\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/A'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/A`
    puts res
    res.should == "hoge\nhoge\n"
  end

  it 'should commit with multi line comment' do
    puts '---- should commit with multi line comment'
    puts '-- modify'
    `echo foo >> /tmp/yggdrasil-test/B`

    puts '-- commit'
    Yggdrasil.command %w{commit / --username hoge --password foo},
                      "Y\ntest commit\\\nmodify B\n"

    puts "\n-- check commit message"
    res = `svn log -r HEAD --xml file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name`
    puts res
    res =~ /<msg>(.*)<\/msg>/m
    $1.should == "test commit\nmodify B"
  end

  it 'should accept password interactive' do
    puts '---- should accept password interactive'
    `echo A >> /tmp/yggdrasil-test/A`

    Yggdrasil.command %w{commit /tmp --username hoge},
                      "foo\nY\nmodify A\n" # interactive input: password,Y/n, commit message

    puts "\n-- check committed file 'tmp/yggdrasil-test/A'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/A`
    puts res
    res.should == "hoge\nhoge\nA\n"
  end

  it 'should commit specified file only' do
    puts '---- should commit specified file only'
    `echo A >> /tmp/yggdrasil-test/A`
    `echo B >> /tmp/yggdrasil-test/B`

    Yggdrasil.command %w{commit
--username hoge --password foo -m modify /tmp/yggdrasil-test/B},
                      "0\nY\n"

    puts "\n-- check committed file 'tmp/yggdrasil-test/B'"
    res = `svn cat file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test/B`
    puts res
    res.should == "foo\nfoo\nB\n"
  end

  it 'should not commit deleted file' do
    puts '---- should not commit deleted file'
    `rm -f /tmp/yggdrasil-test/A`

    Yggdrasil.command %w{commit --username hoge --password foo -m delete},
                      "0\nn\n"
    puts "\n-- check file exists on repo"
    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\nB\n"
  end

  it 'should commit deleted file' do
    puts '---- should commit deleted file'
    `echo hoge > /tmp/yggdrasil-test/A`
    `rm -f /tmp/yggdrasil-test/B`

    Yggdrasil.command %w{commit  -m delete /tmp/yggdrasil-test} +
                          %w{--username hoge --password foo},
                      "0\n1\nY\n"

    puts "\n-- check committed delete file"
    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\n"
  end

  it 'should commit all files at once' do
    puts '---- should commit all files at once'

    `echo HOGE >> /tmp/yggdrasil-test/A`
    `rm -f /tmp/yggdrasil-test/B`
    `mkdir /tmp/yggdrasil-test/c`
    `echo bar > /tmp/yggdrasil-test/c/C`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/c/C}

    Yggdrasil.command %w{commit -m delete /tmp/yggdrasil-test/c/C} +
                          %w{--username hoge --password foo},
                      "0\n1\nY\n"

    puts "\n-- check committed delete file"
    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\nc/\n"
  end

  it 'should commit deleted directory' do
    puts '---- should commit deleted directory'
    `rm -rf /tmp/yggdrasil-test/c`

    Yggdrasil.command %w{commit -m delete --debug} +
                          %w{--username hoge --password foo},
                      "0\n1\nY\n"

    puts "\n-- check committed delete file"
    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\n"
  end

  it 'should commit symbolic link files' do
    puts '---- should commit symbolic link files'
    `ln -s /tmp/yggdrasil-test/A /tmp/yggdrasil-test/B`
    `ln -s /tmp/yggdrasil-test /tmp/yggdrasil-test/c`

puts '1'
    Yggdrasil.command %w{add /tmp/yggdrasil-test/B /tmp/yggdrasil-test/c/A}
puts '2'

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"

0:A tmp/yggdrasil-test/B
1:A tmp/yggdrasil-test/c
2:A tmp/yggdrasil-test/c/A
OK? [A|q|<num to diff>]:#{' '}
EOS
    puts '3'

    Yggdrasil.command %w{commit -m addSymbolicLinks --debug} +
                          %w{--username hoge --password foo},
                      "Y\n"
    puts '4'

    res = `svn ls file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/tmp/yggdrasil-test`
    puts res
    res.should == "A\nB\nc/\n"
    puts '5'

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"
6 files checked.
Yggdrasil check: OK.
EOS

    `echo hoge >> /tmp/yggdrasil-test/A`

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/A
1:M tmp/yggdrasil-test/B
2:M tmp/yggdrasil-test/c/A
OK? [A|q|<num to diff>]:#{' '}
EOS

    Yggdrasil.command %w{commit -m addSymbolicLinks --debug} +
                          %w{--username hoge --password foo},
                      "Y\n"

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"
6 files checked.
Yggdrasil check: OK.
EOS

  end

  it 'should commit only specified files' do
    puts '---- should commit only specified files'

    `echo hoge >> /tmp/yggdrasil-test/A`

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/A
1:M tmp/yggdrasil-test/B
2:M tmp/yggdrasil-test/c/A
OK? [A|q|<num to diff>]:#{' '}
EOS

    out = catch_out do
      Yggdrasil.command %w{commit -m absolutePath --debug /tmp/yggdrasil-test/A} +
                            %w{--username hoge --password foo},
                        "Y\n"
    end
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/A
OK? [Y|n|<num to diff>]:#{' '}
Sending        tmp/yggdrasil-test/A
Transmitting file data .
Committed revision 12.
EOS

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/B
1:M tmp/yggdrasil-test/c/A
OK? [A|q|<num to diff>]:#{' '}
EOS

    out = catch_out do
      FileUtils.cd '/tmp/yggdrasil-test' do
        Yggdrasil.command %w{commit -m absolutePath --debug c} +
                              %w{--username hoge --password foo},
                          "Y\n"
      end
    end
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/c/A
OK? [Y|n|<num to diff>]:#{' '}
Sending        tmp/yggdrasil-test/c/A
Transmitting file data .
Committed revision 13.
EOS

    out = catch_out {Yggdrasil.command %w{c --username hoge --password foo}}
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/B
OK? [A|q|<num to diff>]:#{' '}
EOS

    out = catch_out do
      Yggdrasil.command %w{commit -m absolutePath --debug} +
                            %w{--username hoge --password foo},
                        "Y\n"
    end
    out.should == <<"EOS"

0:M tmp/yggdrasil-test/B
OK? [Y|n|<num to diff>]:#{' '}
Sending        tmp/yggdrasil-test/B
Transmitting file data .
Committed revision 14.
EOS
  end

  it 'should commit with quote character comment' do
    puts '---- should commit with quote character comment'
    `echo A >> /tmp/yggdrasil-test/A`

    out = catch_out do
      Yggdrasil.command %w{commit --debug} +
                            %w{--username hoge --password foo} +
                            %w{-m} + ["with quote<'>"],
                        "Y\n"
    end
    out.should == <<EOS

0:M tmp/yggdrasil-test/A
1:M tmp/yggdrasil-test/B
2:M tmp/yggdrasil-test/c/A
OK? [Y|n|<num to diff>]:#{' '}
Sending        tmp/yggdrasil-test/A
Sending        tmp/yggdrasil-test/B
Sending        tmp/yggdrasil-test/c/A
Transmitting file data ...
Committed revision 15.
EOS

    out = catch_out do
      Yggdrasil.command %w{log -r HEAD --username hoge --password foo}
    end
    out.gsub!(%r{20..-..-.. .*20..\)}, '')
    out.should == <<EOS
------------------------------------------------------------------------
r15 | hoge |  | 1 line

with quote<'>
------------------------------------------------------------------------
EOS

  end

end
