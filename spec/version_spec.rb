require File.dirname(__FILE__) + '/spec_helper'

describe Yggdrasil, "version" do

  show_version = <<"EOS"
#{File.basename($0)}, version #{Yggdrasil::VERSION}

Copyright (C) 2012-2013 Tomohisa Kusukawa.
Yggdrasil is open source software, see https://github.com/tkusukawa/yggdrasil/

EOS

  it 'should show version on "version"' do
    puts '---- should show version on "version"'
    out = catch_out{Yggdrasil.command %w{version}}
    out.should == show_version
  end

  it 'should show version on "--version"' do
    puts '---- should show version on "--version"'
    out = catch_out{Yggdrasil.command %w{--version}}
    out.should == show_version
  end
end
