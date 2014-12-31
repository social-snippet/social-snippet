# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'social_snippet/version'

Gem::Specification.new do |spec|
  spec.name          = "social_snippet"
  spec.version       = SocialSnippet::VERSION
  spec.authors       = ["Hiroyuki Sano"]
  spec.email         = ["sh19910711@gmail.com"]
  spec.summary       = %q{Social Snippet System}
  spec.homepage      = "https://github.com/social-snippet/social-snippet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bundler"
  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "version_sorter"
  spec.add_runtime_dependency "rugged"
  spec.add_runtime_dependency "rest-client"

  spec.add_development_dependency "yard"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-shell"
  spec.add_development_dependency "pry-byebug"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "codeclimate-test-reporter"


end