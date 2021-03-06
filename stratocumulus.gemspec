# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stratocumulus/version"

Gem::Specification.new do |spec|
  spec.name          = "stratocumulus"
  spec.version       = Stratocumulus::VERSION
  spec.authors       = ["Ed Robinson"]
  spec.email         = ["ed.robinson@reevoo.com"]
  spec.summary       = "Backup Databases to Cloud Storage"
  spec.description   = "Backup Databases to Cloud Storage"
  spec.homepage      = "https://github.com/reevoo/stratocumulus"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["stratocumulus"]
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ["lib"]

  spec.add_dependency "fog-aws", "~> 0.9"
  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "reevoocop"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "simplecov"
end
