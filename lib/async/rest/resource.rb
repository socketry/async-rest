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

require 'async'
require 'async/http/client'
require 'async/http/accept_encoding'
require 'async/http/reference'
require 'async/http/url_endpoint'

module Async
	module REST
		# The key abstraction of information in REST is a resource. Any information that can be named can be a resource: a document or image, a temporal service (e.g. "today's weather in Los Angeles"), a collection of other resources, a non-virtual object (e.g. a person), and so on. In other words, any concept that might be the target of an author's hypertext reference must fit within the definition of a resource. A resource is a conceptual mapping to a set of entities, not the entity that corresponds to the mapping at any particular point in time.
		class Resource < HTTP::Middleware
			# @param delegate [Async::HTTP::Middleware] the delegate that will handle requests.
			# @param reference [Async::HTTP::Reference] the resource identifier (base request path/parameters).
			# @param headers [Async::HTTP::Headers] the default headers that will be supplied with the request.
			def initialize(delegate, reference = HTTP::Reference.parse, headers = HTTP::Headers.new)
				super(delegate)
				
				@reference = reference
				@headers = headers
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
				
				Async.run do
					begin
						yield resource
					ensure
						resource.close
					end
				end
			end
			
			attr :reference
			attr :headers
			
			def self.with(parent, *args, headers: {}, parameters: nil, path: nil)
				reference = parent.reference.dup(path, parameters)
				
				self.new(*args, parent.delegate, reference, parent.headers.merge(headers))
			end
			
			def with(*args, **options)
				self.class.with(self, *args, **options)
			end
			
			def get(klass = Representation, **parameters)
				klass.new(self.with(parameters: parameters)).tap(&:value)
			end
			
			# @param verb [String] the HTTP verb to use.
			# @param payload [Object] the object which will used to generate the body of the request.
			def prepare_request(verb, payload)
				if payload
					headers = @headers.dup
					body = yield payload, headers
				else
					headers = @headers
					body = nil
				end
				
				return HTTP::Request[verb, @reference, headers, body]
			end
			
			def inspect
				"\#<#{self.class} #{@reference.inspect} #{@headers.inspect}>"
			end
			
			def to_s
				"\#<#{self.class} #{@reference.to_s}>"
			end
		end
	end
end
