# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require 'sus/fixtures/async/reactor_context'
require 'async/rest/resource'
require 'async/rest/representation'

module DNS
	class Query < Async::REST::Representation
		def initialize(*arguments)
			super(*arguments, wrapper: Async::REST::Wrapper::JSON.new)
		end
		
		def question
			value[:Question]
		end
		
		def answer
			value[:Answer]
		end
	end
end

describe Async::REST::Resource do
	include Sus::Fixtures::Async::ReactorContext
	
	let(:url) {'https://dns.google.com/resolve'}
	let(:resource) {subject.for(url)}
	
	it "can get resource" do
		# The first argument is the representation class to use:
		query = resource.get(DNS::Query, name: 'example.com', type: 'AAAA')
		
		expect(query.value).to have_keys(:Question, :Answer)
		
		resource.close
	end
end
