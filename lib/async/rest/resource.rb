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

require_relative 'reference'
require_relative 'json_body'

require 'async/http/client'
require 'async/http/url_endpoint'

module Async
	module REST
		class Resource
			DEFAULT_HEADERS = {
				'accept-encoding' => 'gzip',
				'accept' => 'application/json;q=0.9, */*;q=0.8'
			}
			
			def initialize(client, reference = Reference.parse, headers = DEFAULT_HEADERS, max_redirects: 10)
				@client = client
				@reference = reference
				@headers = headers
				
				@max_redirects = max_redirects
			end
			
			def close
				@client.close
			end
			
			def self.for(url, headers = {}, **options)
				endpoint = HTTP::URLEndpoint.parse(url)
				client = HTTP::Client.new(endpoint)
				
				resource = self.new(client, Reference.parse(endpoint.url.request_uri), headers)
				
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
			
			attr :max_redirects
			
			def [] path
				self.class.new(@client, @reference.nest(path), @headers, max_redirects: @max_redirects)
			end
			
			def with(**headers)
				self.class.new(@client, @reference, @headers.merge(headers), max_redirects: @max_redirects)
			end
			
			def wrapper_for(content_type)
				if content_type == 'application/json'
					return JSONBody
				end
			end
			
			def prepare_body(payload)
				return [] if payload.nil?
				
				content_type = @headers['content-type']
				
				if wrapper = wrapper_for(content_type)
					return wrapper.dump(payload)
				else
					raise ArgumentError.new("Unsure how to convert payload to #{content_type}!")
				end
			end
			
			def process_response(response)
				response.body = HTTP::InflateBody.for_response(response)
				
				content_type = response.headers['content-type']
				
				if wrapper = wrapper_for(content_type)
					response.body = wrapper.new(response.body)
				end
				
				return response
			end
			
			HTTP::Client::VERBS.each do |verb|
				define_method(verb.downcase) do |payload = nil, **parameters, &block|
					reference = @reference.dup(nil, parameters)
					
					if body = prepare_body(payload)
						body = HTTP::DeflateBody.for_request(@headers, body)
					end
					
					response = self.request(verb, reference.to_str, @headers, body) do |response|
						process_response(response)
					end
					
					return response
				end
			end
			
			def request(verb, location, *args)
				@max_redirects.times do
					@client.request(verb, location, *args) do |response|
						if response.redirection?
							verb = 'GET' unless response.preserve_method?
							location = response.headers['location']
						else
							return yield response
						end
					end
				end
				
				raise ArgumentError.new("Too many redirections!")
			end
		end
	end
end
