# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require 'sus/fixtures/async/http/server_context'

require 'async/http/server'
require 'async/http/endpoint'
require 'async/rest/resource'
require 'async/rest/representation'
require 'async/io/shared_endpoint'

AWrapper = Sus::Shared("a wrapper") do
	include Sus::Fixtures::Async::HTTP::ServerContext
	
	let(:representation) {Async::REST::Representation.for(bound_url, wrapper: wrapper)}
	
	let(:middleware) do
		Protocol::HTTP::Middleware.for do |request|
			if request.headers['content-type'] == wrapper.content_type
				# Echo it back:
				Protocol::HTTP::Response[200, request.headers, request.body]
			else
				Protocol::HTTP::Response[400, {}, ["Invalid content type!"]]
			end
		end
	end
	
	let(:payload) {{username: "Frederick", password: "Fish"}}
	
	it "can post payload representation" do
		response = representation.post(payload)
		
		expect(response).to be(:success?)
		expect(response.read).to be == payload
		
		representation.close
	end
end
