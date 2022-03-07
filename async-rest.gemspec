# frozen_string_literal: true

require_relative "lib/async/rest/version"

Gem::Specification.new do |spec|
	spec.name = "async-rest"
	spec.version = Async::REST::VERSION
	
	spec.summary = "A library for RESTful clients (and hopefully servers)."
	spec.authors = ["Samuel Williams", "Olle Jonsson", "Terry", "Cyril Roelandt"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/async-rest"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "async-http", "~> 0.42"
	spec.add_dependency "protocol-http", "~> 0.7"
	
	spec.add_development_dependency "async-rspec", "~> 1.1"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rake"
	spec.add_development_dependency "rspec", "~> 3.6"
end
