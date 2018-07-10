source 'https://rubygems.org'

# Specify your gem's dependencies in async-io.gemspec
gemspec

group :development do
	gem 'pry'
end

group :test do
	gem 'covered', require: 'covered/rspec' if RUBY_VERSION >= "2.6.0"
end
