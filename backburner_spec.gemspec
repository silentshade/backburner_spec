# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backburner_spec/version'

Gem::Specification.new do |spec|
  spec.name          = "backburner_spec"
  spec.version       = BackburnerSpec::VERSION
  spec.authors       = ["Oleg German"]
  spec.email         = ["oleg.german@gmail.com"]
  spec.description   = %q{RSpec matchers and helpers for Backburner}
  spec.summary       = %q{Inspired by resque_spec gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('backburner', ['>= 0.4.3'])
  spec.add_runtime_dependency('rspec-core', ["~> 2.99"])
  spec.add_runtime_dependency('rspec-expectations', ["~> 2.99"])
  spec.add_runtime_dependency('rspec-mocks', ["~> 2.99"])

  spec.add_development_dependency "timecop"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "rspec"
end
