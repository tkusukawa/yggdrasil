require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "diff" do
  before do
    puts '-------- before do (diff)'
    `rm -rf /tmp/yggdrasil-test`
    Dir.mkdir('/tmp/yggdrasil-test', 0755)
    ENV['HOME']='/tmp/yggdrasil-test'

    # init
    `svnadmin create /tmp/yggdrasil-test/svn-repo`
    Yggdrasil.command %w{init --repo file:///tmp/yggdrasil-test/svn-repo/mng-repo/host-name/} +
                      %w{--username hoge --password foo}

    # add files and commit
    `echo hoge > /tmp/yggdrasil-test/A`
    `echo foo > /tmp/yggdrasil-test/B`
    FileUtils.cd "/tmp/yggdrasil-test" do
      Yggdrasil.command %w{add A B}
      Yggdrasil.command %w{commit --non-interactive --username hoge --password foo -m add\ A}
    end

    # modify A and commit
    `echo foo >> /tmp/yggdrasil-test/A`
    FileUtils.cd "/tmp/yggdrasil-test" do
      Yggdrasil.command %w{commit --non-interactive --username hoge --password foo -m modify\ A}
    end

    # modify and not commit yet
    `echo HOGE >> /tmp/yggdrasil-test/A`
    `echo FOO >> /tmp/yggdrasil-test/B`
  end

  it 'should success diff (local - repo)' do
    puts "---- should success diff (local - repo)"
    puts "-- absolute and relative"
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
 foo
+HOGE
Index: tmp/yggdrasil-test/B
===================================================================
--- tmp/yggdrasil-test/B	(revision 2)
+++ tmp/yggdrasil-test/B	(working copy)
@@ -1 +1,2 @@
 foo
+FOO
EOS

    puts "-- specify revision (-r)"
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
+foo
EOS

    puts "-- specify revision (--revision)"
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
 foo
+HOGE
EOS
  end
end
