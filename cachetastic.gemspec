# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cachetastic/version'

Gem::Specification.new do |gem|
  gem.name          = "cachetastic"
  gem.version       = Cachetastic::VERSION
  gem.authors       = ["Mark Bates"]
  gem.email         = ["mark@markbates.com"]
  gem.description   = %q{A very simple, yet very powerful caching framework for Ruby.}
  gem.summary       = %q{A very simple, yet very powerful caching framework for Ruby.}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_dependency "configatron"
  gem.add_dependency "activesupport"
end
