# frozen_string_literal: true

require_relative "lib/async/rest/version"

Gem::Specification.new do |spec|
	spec.name = "async-rest"
	spec.version = Async::REST::VERSION
	
	spec.summary = "A library for RESTful clients (and hopefully servers)."
	spec.authors = ["Samuel Williams", "Olle Jonsson", "Cyril Roelandt", "Terry Kerr"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-rest"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-rest/",
		"source_code_uri" => "https://github.com/socketry/async-rest.git",
	}
	
	spec.files = Dir.glob(["{lib}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "async-http", "~> 0.42"
	spec.add_dependency "protocol-http", "~> 0.45"
end
