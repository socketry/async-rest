# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.
# Copyright, 2021, by Terry Kerr.

require_relative 'error'
require_relative 'resource'
require_relative 'wrapper/json'

module Async
	module REST
		# A representation of a resource has a value at the time the representation was created or fetched. It is usually generated by performing an HTTP request.
		#
		# REST components perform actions on a resource by using a representation to capture the current or intended state of that resource and transferring that representation between components. A representation is a sequence of bytes, plus representation metadata to describe those bytes. Other commonly used but less precise names for a representation include: document, file, and HTTP message entity, instance, or variant.
		# 
		# A representation consists of data, metadata describing the data, and, on occasion, metadata to describe the metadata (usually for the purpose of verifying message integrity). Metadata is in the form of name-value pairs, where the name corresponds to a standard that defines the value's structure and semantics. Response messages may include both representation metadata and resource metadata: information about the resource that is not specific to the supplied representation.
		class Representation
			WRAPPER = Wrapper::JSON.new
			
			def self.[] wrapper
				klass = Class.new(self)
				
				if wrapper.is_a?(Class)
					wrapper = wrapper.new
				end
				
				klass.const_set(:WRAPPER, wrapper)
				
				return klass
			end
			
			class << self
				::Protocol::HTTP::Methods.each do |name, verb|
					define_method(verb.downcase) do |resource, payload = nil|
						self::WRAPPER.call(resource, verb, payload) do |response|
							return self.for(resource, response)
						end
					end
				end
			end
			
			def self.for(resource, response)
				self.new(resource, metadata: response.headers, value: response.read)
			end
			
			# @param resource [Resource] the RESTful resource that this representation is of.
			# @param metadata [Hash | HTTP::Headers] the metadata associated with the representation.
			# @param value [Object] the value of the representation.
			def initialize(resource, value: nil, metadata: {})
				@resource = resource
				
				@value = value
				@metadata = metadata
			end
			
			def with(klass = nil, **options)
				if klass
					klass.new(@resource.with(**options))
				else
					self.class.new(@resource.with(**options))
				end
			end
			
			def [] **parameters
				self.with(parameters: parameters)
			end
			
			def close
				@resource.close
			end
			
			attr :resource
			attr :metadata
			
			private def get
				self.class::WRAPPER.call(@resource) do |response|
					if response.success?
						@metadata = response.headers
						@value = response.read
					else
						raise ResponseError, response
					end
				end
			end
			
			def value?
				!@value.nil?
			end
			
			def value
				@value ||= self.get
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
