# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_object/version'

Gem::Specification.new do |spec|
  spec.name          = 'method_man'
  spec.version       = MethodObject::VERSION
  spec.authors       = ['Clay Shentrup']
  spec.email         = %w[cshentrup@gmail.com]
  spec.summary       = %(Provides a MethodObject class which implements KentBeck's "method object" pattern.)
  spec.description   = %(Provides a MethodObject class which implements KentBeck's "method object" pattern.)
  spec.homepage      = 'https://github.com/brokenladder/method_man'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rubocop')
end
