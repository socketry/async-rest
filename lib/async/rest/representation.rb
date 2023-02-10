# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.
# Copyright, 2021, by Terry Kerr.

require_relative 'error'
require_relative 'resource'
require_relative 'wrapper/json'

module Async
	module REST
		# REST components perform actions on a resource by using a representation to capture the current or intended state of that resource and transferring that representation between components. A representation is a sequence of bytes, plus representation metadata to describe those bytes. Other commonly used but less precise names for a representation include: document, file, and HTTP message entity, instance, or variant.
		# 
		# A representation consists of data, metadata describing the data, and, on occasion, metadata to describe the metadata (usually for the purpose of verifying message integrity). Metadata is in the form of name-value pairs, where the name corresponds to a standard that defines the value's structure and semantics. Response messages may include both representation metadata and resource metadata: information about the resource that is not specific to the supplied representation.
		class Representation
			def self.[] wrapper
				klass = Class.new(self)
				
				klass.const_set(:WRAPPER, wrapper)
				
				return klass
			end
			
			def self.for(*arguments, **options)
				representation = self.new(Resource.for(*arguments), **options)
				
				return representation unless block_given?
				
				Async do
					begin
						yield representation
					ensure
						representation.close
					end
				end
			end
			
			WRAPPER = Wrapper::JSON
			
			# @param resource [Resource] the RESTful resource that this representation is of.
			# @param metadata [Hash | HTTP::Headers] the metadata associated wtih teh representation.
			# @param value [Object] the value of the representation.
			# @param wrapper [#prepare_request, #process_response] the wrapper for encoding/decoding the request/response body.
			def initialize(resource, metadata: {}, value: nil, wrapper: self.class::WRAPPER.new)
				@resource = resource
				@wrapper = wrapper
				
				@metadata = metadata
				@value = value
			end
			
			def with(klass = nil, **options)
				if klass
					klass.new(@resource.with(**options), wrapper: klass::WRAPPER.new)
				else
					self.class.new(@resource.with(**options), wrapper: @wrapper)
				end
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
			
			# If an exception propagates out of this method, the response will be closed.
			def process_response(request, response)
				@wrapper.process_response(request, response)
			end
			
			::Protocol::HTTP::Methods.each do |name, verb|
				# TODO when Ruby 3.0 lands, convert this to |payload = nil, **parameters|
				# Blocked by https://bugs.ruby-lang.org/issues/14183
				define_method(verb.downcase) do |payload = nil|
					request = prepare_request(verb, payload)
					
					response = @resource.call(request)
					
					# If we exit this block because of an exception, we close the response. This ensures we don't have any dangling connections.
					begin
						return process_response(request, response)
					rescue
						response.close
						
						raise
					end
				end
			end
			
			attr :metadata
			
			def value!
				response = self.get
				
				if response.success?
					@metadata = response.headers
					@value = response.read
				else
					raise ResponseError, response
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
