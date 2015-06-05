# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_object/version'

Gem::Specification.new do |spec|
  spec.name          = 'method_man'
  spec.version       = MethodObject::VERSION
  spec.authors       = ['Clay Shentrup']
  spec.email         = %w(cshentrup@gmail.com)
  spec.summary       = %q{Provides a MethodObject class which implements Kent Beck's "method object" pattern.}
  spec.description   = %q{Provides a MethodObject class which implements Kent Beck's "method object" pattern.}
  spec.homepage      = 'https://github.com/brokenladder/method_man'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.2'
end
