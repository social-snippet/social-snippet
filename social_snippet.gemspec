# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'social_snippet/version'

Gem::Specification.new do |spec|
  spec.name          = "social_snippet"
  spec.version       = SocialSnippet::VERSION
  spec.authors       = ["Hiroyuki Sano"]
  spec.email         = ["sh19910711@gmail.com"]
  spec.summary       = %q{A snippet manager to share and use snippet library for the online judges; Google Code Jam, Codeforces, ACM/ICPC and etc...}
  spec.homepage      = "https://github.com/social-snippet/social-snippet"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_runtime_dependency "version_sorter", "~> 2.0.0"
  spec.add_runtime_dependency "rest-client", "~> 1.8.0"
  spec.add_runtime_dependency "highline", "~> 1.7.0"
  spec.add_runtime_dependency "wisper", "~> 1.6.0"
  spec.add_runtime_dependency "social_snippet-supports-git", "~> 0.1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-shell"

  if ENV["SOCIAL_SNIPPET_DEBUG"] == "true"
    spec.add_development_dependency "pry"
    spec.add_development_dependency "pry-byebug"
  end

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "codeclimate-test-reporter"


end
