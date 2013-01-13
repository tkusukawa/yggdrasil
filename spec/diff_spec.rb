require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "diff" do
  it '-------- diff' do
    puts '-------- diff'
    prepare_environment
    init_yggdrasil

    # modify and not commit yet
    `echo HOGE >> /tmp/yggdrasil-test/A`
    `echo FOO >> /tmp/yggdrasil-test/B`
  end

  it 'should success diff (absolute/relative path)' do
    puts "---- should success diff (absolute/relative path)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command(%w{diff /tmp/yggdrasil-test/A B --username hoge --password foo})
      end
    end
    out.should == <<"EOS"
Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 3)
+++ tmp/yggdrasil-test/A	(working copy)
@@ -1,2 +1,3 @@
 hoge
 hoge
+HOGE
Index: tmp/yggdrasil-test/B
===================================================================
--- tmp/yggdrasil-test/B	(revision 3)
+++ tmp/yggdrasil-test/B	(working copy)
@@ -1,2 +1,3 @@
 foo
 foo
+FOO
EOS
  end

  it 'should success (no path)' do
    puts "---- should success (no path)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{diff --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A\t(revision 3)
+++ tmp/yggdrasil-test/A\t(working copy)
@@ -1,2 +1,3 @@
 hoge
 hoge
+HOGE
Index: tmp/yggdrasil-test/B
===================================================================
--- tmp/yggdrasil-test/B\t(revision 3)
+++ tmp/yggdrasil-test/B\t(working copy)
@@ -1,2 +1,3 @@
 foo
 foo
+FOO
EOS
  end

  it 'should success (-r)' do
    puts "---- should success (-r)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{diff -r 2:3 A --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 2)
+++ tmp/yggdrasil-test/A	(revision 3)
@@ -1 +1,2 @@
 hoge
+hoge
EOS
  end

  it 'should success (--revision)' do
    puts "---- should success (--revision)"
    out = catch_stdout do
      FileUtils.cd "/tmp/yggdrasil-test" do
        Yggdrasil.command %w{diff --revision 3 A --username hoge --password foo}
      end
    end
    out.should == <<"EOS"
Index: tmp/yggdrasil-test/A
===================================================================
--- tmp/yggdrasil-test/A	(revision 3)
+++ tmp/yggdrasil-test/A	(working copy)
@@ -1,2 +1,3 @@
 hoge
 hoge
+HOGE
EOS
  end
end
