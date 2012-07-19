# -*- encoding: utf-8 -*-
require File.expand_path('../lib/prosper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Evan Farrar"]
  gem.email         = ["evanfarrar@gmail.com"]
  gem.description   = %q{A wrapper for the prosper.com API}
  gem.summary       = %q{A wrapper for the prosper.com API}
  gem.homepage      = "http://gihub.com/evanfarrar/prosper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "prosper"
  gem.require_paths = ["lib"]
  gem.version       = Prosper::VERSION
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "guard-rspec"
  gem.add_dependency "httparty"
  gem.add_dependency "lolsoap"
  gem.add_dependency "facets"
end
