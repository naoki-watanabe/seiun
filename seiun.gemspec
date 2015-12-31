# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seiun/version'

Gem::Specification.new do |spec|
  spec.name          = "seiun"
  spec.version       = Seiun::VERSION
  spec.authors       = ["Naoki Watanabe"]
  spec.email         = ["naoki.watanabe@ikina.org"]

  spec.summary       = %q{Salesforce Adapter for Ruby environment.}
  spec.description   = %q{You can communicate Salesforce via Bulk API from ruby environment.}
  spec.homepage      = "https://github.com/naoki-watanabe/seiun"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'databasedotcom', '>= 1.0.8'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
