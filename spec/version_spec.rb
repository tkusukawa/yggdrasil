require File.dirname(__FILE__) + '/../lib/yggdrasil'

describe Yggdrasil, "version" do
  show_version = <<"EOS"
#{File.basename($0)}, version #{Yggdrasil::VERSION}

Copyright (C) 2012-2013 Tomohisa Kusukawa.
Yggdrasil is open source software, see https://github.com/tkusukawa/yggdrasil/

EOS

  it 'should show version on "version"' do
    $stdout = StringIO.new
    Yggdrasil.command %w{version}
    $stdout.string.should == show_version
  end

  it 'should show version on "--version"' do
    $stdout = StringIO.new
    Yggdrasil.command %w{--version}
    $stdout.string.should == show_version
  end

end
