# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'wrapper/json'

require 'async/http/client'
require 'async/http/accept_encoding'
require 'async/http/reference'
require 'async/http/url_endpoint'

module Async
	module REST
		class Resource < HTTP::Middleware
			# @param delegate [Async::HTTP::Middleware] the delegate that will handle requests.
			# @param reference [Async::HTTP::Reference] the base request path/parameters.
			# @param headers [Async::HTTP::Headers] the default headers that will be supplied with the request.
			# @param wrapper [#prepare_request, #process_response] the wrapper for encoding/decoding the request/response body.
			def initialize(delegate, reference = HTTP::Reference.parse, headers = HTTP::Headers.new, wrapper = Wrapper::JSON.new)
				super(delegate)
				
				@reference = reference
				@headers = headers
				@wrapper = wrapper
			end
			
			def self.connect(url)
				endpoint = HTTP::URLEndpoint.parse(url)
				
				reference = HTTP::Reference.parse(endpoint.path)
				
				# return HTTP::Client.new(endpoint), reference
				return HTTP::AcceptEncoding.new(HTTP::Client.new(endpoint)), reference
			end
			
			def self.for(url, *args)
				client, reference = connect(url)
				
				resource = self.new(client, reference, *args)
				
				return resource unless block_given?
				
				begin
					yield resource
				ensure
					resource.close
				end
			end
			
			attr :reference
			attr :headers
			attr :wrapper
			
			def self.with(parent, *args, headers: {}, parameters: nil, path: nil, wrapper: parent.wrapper)
				self.new(*args, parent.delegate, parent.reference.dup(path, parameters), parent.headers.merge(headers), wrapper)
			end
			
			def with(*args, **options)
				self.class.with(self, *args, **options)
			end
			
			def prepare_request(verb, payload = nil, **parameters)
				if parameters.empty?
					reference = @reference
				else
					reference = @reference.dup(nil, parameters)
				end
				
				headers = @headers.dup
				
				if payload
					body = @wrapper.prepare_request(payload, headers)
				else
					body = nil
				end
				
				return HTTP::Request[verb, reference, headers, body]
			end
			
			def process_response(response)
				@wrapper.process_response(response)
			end
			
			HTTP::VERBS.each do |verb|
				define_method(verb.downcase) do |*args|
					request = prepare_request(verb, *args)
					
					response = self.call(request)
					
					process_response(response)
				end
			end
		end
	end
end
