
require 'bundler/setup'

Bundler.require(:test)

require 'async/http'
require 'async/rspec/reactor'

# Async.logger.level = Logger::DEBUG

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
