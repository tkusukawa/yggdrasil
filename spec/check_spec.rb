require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "check" do
  it '-------- check' do
    puts '-------- check'
    prepare_environment
    init_yggdrasil
  end

  it 'should execute checker and svn add the result' do
    puts "\n---- should execute checker and svn add the result"
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/gem_list`
    `echo 'echo hoge' > /tmp/yggdrasil-test/.yggdrasil/checker/hoge`
    `chmod +x /tmp/yggdrasil-test/.yggdrasil/checker/hoge`

    cmd = %w{check --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd)}
    out.should == <<"EOS"
A                0   tmp/yggdrasil-test/.yggdrasil/checker_result
A                0   tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
A                0   tmp/yggdrasil-test/.yggdrasil

Index: tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 0)
+++ tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 0)
@@ -0,0 +1 @@
+hoge
EOS
  end

  it 'should commit the checker result' do
    puts "\n---- should commit the checker result"
    cmd = %w{commit / --username hoge --password foo --non-interactive -m add\ checker}
    out = catch_out {Yggdrasil.command cmd}

    out.should == <<"EOS"
Adding         tmp/yggdrasil-test/.yggdrasil
Adding         tmp/yggdrasil-test/.yggdrasil/checker_result
Adding         tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
Transmitting file data .
Committed revision 4.
EOS
  end

  it 'should delete result if checker deleted' do
    puts "\n---- should delete result if checker deleted"
    `rm -f /tmp/yggdrasil-test/.yggdrasil/checker/hoge`
    cmd = %w{check --username hoge --password foo}
    out = catch_out {Yggdrasil.command(cmd)}
    out.should == <<"EOS"
D                4   tmp/yggdrasil-test/.yggdrasil/checker_result/hoge

Index: tmp/yggdrasil-test/.yggdrasil/checker_result/hoge
===================================================================
--- tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(revision 4)
+++ tmp/yggdrasil-test/.yggdrasil/checker_result/hoge	(working copy)
@@ -1 +0,0 @@
-hoge
EOS
  end

  it 'should commit the checker result(delete)' do
    puts "\n---- should commit the checker result(delete)"
    cmd = %w{commit / --username hoge --password foo --non-interactive -m delete\ checker}
    out = catch_out {Yggdrasil.command cmd}

    out.should == <<"EOS"
Deleting       tmp/yggdrasil-test/.yggdrasil/checker_result/hoge

Committed revision 5.
EOS
  end

  it 'should setup with server' do
    puts "\n---- should setup with server"
    pending("under construction")
  end
end
