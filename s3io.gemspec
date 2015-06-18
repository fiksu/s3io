# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3io/version'

Gem::Specification.new do |gem|
  gem.name          = "s3io"
  gem.version       = S3io::VERSION
  gem.authors       = ["Arthur Pirogovski"]
  gem.email         = ["arthur@flyingtealeaf.com"]
  gem.description   = %q{An IO-compatible wrapper for S3}
  gem.summary       = %q{Amazon's official AWS SDK provides an API for S3 that isn't compatible with Ruby's standard IO class and its derivatives. This gem provides a thin wrapper around AWS SDK that makes it possible to access objects stored on S3 as if they were instances of File or StringIO classes.}
  gem.homepage      = "http://github.com/fiksu/s3io"

  gem.add_development_dependency('aws-sdk', "~> 1.64.0")

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  if RUBY_VERSION >= '2.2'
    gem.add_development_dependency "test-unit", "~> 3.0.8"
  end
end
