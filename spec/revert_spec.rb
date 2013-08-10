require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, 'revert' do
  it '-------- revert' do
    puts '-------- revert'
    prepare_environment
    init_yggdrasil
  end


  it 'should revert added files' do
    puts '---- should commit added files'
    `echo hoge > /tmp/yggdrasil-test/AA`
    `echo foo > /tmp/yggdrasil-test/BB`
    FileUtils.cd '/tmp/yggdrasil-test' do
      puts '-- add'
      Yggdrasil.command %w{add AA /tmp/yggdrasil-test/BB}

      puts '-- revert'
      Yggdrasil.command %w{revert --username hoge --password foo},
                        "0\nY\n"
    end

    puts "\n-- check revert file (add)"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.should == "no files.\n"
  end

  it 'should revert modified file' do
    puts '---- should revert modified file'
    puts '-- modify'
    `echo hoge >> /tmp/yggdrasil-test/A`

    puts '-- revert'
    Yggdrasil.command %w{revert / --username hoge --password foo},
                      "0\nY\n"

    puts "\n-- check revert file (modify)"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.should == "no files.\n"
  end

  it 'should accept password interactive' do
    puts '---- should accept password interactive'
    `echo A >> /tmp/yggdrasil-test/A`

    Yggdrasil.command %w{revert /tmp/yggdrasil-test/A --username hoge},
                      "foo\nY\n" # interactive input: password, Y/n

    puts "\n-- check revert file"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.should == "no files.\n"
  end

  it 'should revert specified file only' do
    puts '---- should revert specified file only'
    `echo A >> /tmp/yggdrasil-test/A`
    `echo B >> /tmp/yggdrasil-test/B`

    Yggdrasil.command %w{revert /tmp/yggdrasil-test/B} +
                          %w{--username hoge --password foo},
                      "0\nY\n"

    puts "\n-- check revert file"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.gsub!(%r{ +}, ' ')
    out.should == <<"EOS"
M 3 tmp/yggdrasil-test/A

Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 3)
+++ tmp/yggdrasil-test/A	(working copy)
@@ -1,2 +1,3 @@
 hoge
 hoge
+A

EOS
  end

  it 'should not revert deleted file' do
    puts '---- should not revert deleted file'
    `rm -f /tmp/yggdrasil-test/A`

    Yggdrasil.command %w{revert /} +
                          %w{--username hoge --password foo},
                      "0\nn\n"

    puts "\n-- check status"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.gsub!(%r{ +},' ')
    out.should == <<"EOS"
D 3 tmp/yggdrasil-test/A

Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 3)
+++ tmp/yggdrasil-test/A	(working copy)
@@ -1,2 +0,0 @@
-hoge
-hoge

EOS
  end

  it 'should revert all files at once' do
    puts '---- should revert all files at once'

    `echo HOGE >> /tmp/yggdrasil-test/A`
    `rm -f /tmp/yggdrasil-test/B`
    `mkdir /tmp/yggdrasil-test/c`
    `echo bar > /tmp/yggdrasil-test/c/C`
    Yggdrasil.command %w{add /tmp/yggdrasil-test/c/C}

    Yggdrasil.command %w{revert /} +
                          %w{--username hoge --password foo},
                      "0\nY\n"

    puts "\n-- check status"
    out = catch_out do
      Yggdrasil.command %w{check /tmp/yggdrasil-test --non-interactive} +
                            %w{--username hoge --password foo}
    end
    puts out
    out.should == "no files.\n"
  end
end
