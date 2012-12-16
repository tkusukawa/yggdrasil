# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yggdrasil/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["tkusukawa"]
  gem.email         = ["t.kusukawa@gmail.com"]
  gem.description   = %q{ruby script to manage server configurations by subversion.}
  gem.summary       = %q{ruby script to manage server configurations by subversion.}
  gem.homepage      = "https://github.com/tkusukawa/yggdrasil"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yggdrasil"
  gem.require_paths = ["lib"]
  gem.version       = Yggdrasil::VERSION
end
