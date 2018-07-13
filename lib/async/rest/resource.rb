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

require_relative 'middleware/json'

require 'async/http/client'
require 'async/http/accept_encoding'
require 'async/http/reference'
require 'async/http/url_endpoint'

module Async
	module REST
		class Resource < HTTP::Middleware
			def initialize(client, reference = HTTP::Reference.parse, headers = HTTP::Headers.new)
				super(client)
				
				@reference = reference
				@headers = headers
			end
			
			def self.connect(url)
				endpoint = HTTP::URLEndpoint.parse(url)
				
				reference = HTTP::Reference.parse(endpoint.url.request_uri)
				
				return HTTP::AcceptEncoding.new(HTTP::Client.new(endpoint)), reference
			end
			
			def self.wrap(client)
				Middleware::JSON.new(client)
			end
			
			def self.for(url, wrapper_klass = Middleware::JSON, *args)
				client, reference = connect(url)
				
				resource = self.new(wrap(client), reference, *args)
				
				return resource unless block_given?
				
				begin
					yield resource
				ensure
					resource.close
				end
			end
			
			attr :client
			attr :reference
			attr :headers
			
			def self.nest(parent, path = nil, *args)
				self.new(*args, parent.client, parent.reference.dup(path), parent.headers)
			end
			
			def with(**headers)
				self.class.new(@client, @reference, @headers.merge(headers))
			end
			
			def prepare_request(verb, body = nil, headers = nil, **parameters)
				headers ||= @headers.dup
				reference = @reference.dup(nil, parameters)
				
				return HTTP::Request[verb, reference, headers, body]
			end
			
			HTTP::VERBS.each do |verb|
				define_method(verb.downcase) do |*args|
					self.call(prepare_request(verb, *args))
				end
			end
		end
	end
end
