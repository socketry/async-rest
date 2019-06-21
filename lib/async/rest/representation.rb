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

require_relative 'error'
require_relative 'resource'
require_relative 'wrapper/json'

module Async
	module REST
		# REST components perform actions on a resource by using a representation to capture the current or intended state of that resource and transferring that representation between components. A representation is a sequence of bytes, plus representation metadata to describe those bytes. Other commonly used but less precise names for a representation include: document, file, and HTTP message entity, instance, or variant.
		# 
		# A representation consists of data, metadata describing the data, and, on occasion, metadata to describe the metadata (usually for the purpose of verifying message integrity). Metadata is in the form of name-value pairs, where the name corresponds to a standard that defines the value's structure and semantics. Response messages may include both representation metadata and resource metadata: information about the resource that is not specific to the supplied representation.
		class Representation
			def self.for(*args, **options)
				self.new(Resource.for(*args), **options)
			end
			
			# @param resource [Resource] the RESTful resource that this representation is of.
			# @param metadata [Hash | HTTP::Headers] the metadata associated wtih teh representation.
			# @param value [Object] the value of the representation.
			# @param wrapper [#prepare_request, #process_response] the wrapper for encoding/decoding the request/response body.
			def initialize(resource, metadata: {}, value: nil, wrapper: Wrapper::JSON.new)
				@resource = resource
				@wrapper = wrapper
				
				@metadata = metadata
				@value = value
			end
			
			def with(klass = self.class, **options)
				klass.new(@resource.with(**options), wrapper: @wrapper)
			end
			
			def [] **parameters
				self.with(parameters: parameters)
			end
			
			def close
				@resource.close
			end
			
			attr :resource
			attr :wrapper
			
			def prepare_request(verb, payload)
				@resource.prepare_request(verb, payload, &@wrapper.method(:prepare_request))
			end
			
			def process_response(request, response)
				@wrapper.process_response(request, response)
			end
			
			::Protocol::HTTP::Methods.each do |name, verb|
				# TODO when Ruby 3.0 lands, convert this to |payload = nil, **parameters|
				# Blocked by https://bugs.ruby-lang.org/issues/14183
				define_method(verb.downcase) do |payload = nil|
					request = prepare_request(verb, payload)
					
					response = @resource.call(request)
					
					process_response(request, response)
				end
			end
			
			attr :metadata
			
			def value!
				response = self.get
				
				if response.success?
					@metadata = response.headers
					@value = response.read
				else
					
				end
			end
			
			def value?
				!@value.nil?
			end
			
			def value
				@value ||= value!
			end
			
			def value= value
				@value = self.assign(value)
			end
			
			def call(value)
				if value
					self.post(value)
				else
					self.delete
				end
			end
			
			def assign(value)
				response = self.call(value)
				
				response.read
				
				return @value
			end
			
			def update
				@value = assign(@value)
			end
			
			def inspect
				"\#<#{self.class} #{@resource.inspect}: value=#{@value.inspect}>"
			end
		end
	end
end
