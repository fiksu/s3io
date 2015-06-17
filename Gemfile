source 'https://rubygems.org'

# Specify your gem's dependencies in s3io.gemspec
gemspec

gem "rake"

group :development do
  platforms :ruby do
    gem "yard"
    gem "redcarpet"
  end
end

gem "test-unit", :group => :test if RUBY_VERSION >= '2.2'
