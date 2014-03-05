# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'services/version'

Gem::Specification.new do |spec|
  spec.name                  = "services"
  spec.version               = Services::VERSION
  spec.authors               = ["Sam Taylor"]
  spec.email                 = ["sjltaylor@gmail.com"]
  spec.description           = %q{TODO: Write a gem description}
  spec.summary               = %q{TODO: Write a gem summary}
  spec.homepage              = ""
  spec.license               = "MIT"
  spec.required_ruby_version = '>= 2.1.1'

  spec.files                 = `git ls-files`.split($/)
  spec.executables           = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files            = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths         = ["lib"]

  spec.add_dependency "activesupport"
  #spec.add_dependency "resolve"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
