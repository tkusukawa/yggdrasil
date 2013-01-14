# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yggdrasil/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tomohisa Kusukawa"]
  gem.email         = %w{t.kusukawa@gmail.com}
  gem.description   = %q{Yggdrasil is a subversion wrapper to manage configuration files.}
  gem.summary       = "Type 'yggdrasil help' for usage."
  gem.homepage      = "https://github.com/tkusukawa/yggdrasil"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yggdrasil"
  gem.require_paths = %w{lib}
  gem.version       = Yggdrasil::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
end
