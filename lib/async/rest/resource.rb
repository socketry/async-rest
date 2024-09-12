# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "async"
require "async/http/client"
require "async/http/endpoint"

require "protocol/http/accept_encoding"
require "protocol/http/reference"

module Async
	module REST
		# A resource is an abstract reference to some named entity, typically a URL with associated metatadata. Generally, your entry to any web service will be a resource, and that resource will create zero or more representations as you navigate through the service.
		#
		# The key abstraction of information in REST is a resource. Any information that can be named can be a resource: a document or image, a temporal service (e.g. "today's weather in Los Angeles"), a collection of other resources, a non-virtual object (e.g. a person), and so on. In other words, any concept that might be the target of an author's hypertext reference must fit within the definition of a resource. A resource is a conceptual mapping to a set of entities, not the entity that corresponds to the mapping at any particular point in time.
		class Resource < ::Protocol::HTTP::Middleware
			ENDPOINT = nil
			
			# Connect to the given endpoint, returning the HTTP client and reference.
			# @parameter endpoint [Async::HTTP::Endpoint] used to connect to the remote system and specify the base path.
			# @returns [Tuple(Async::HTTP::Client, ::Protocol::HTTP::Reference)] the client and reference.
			def self.connect(endpoint)
				reference = ::Protocol::HTTP::Reference.parse(endpoint.path)
				
				return ::Protocol::HTTP::AcceptEncoding.new(HTTP::Client.new(endpoint)), reference
			end
			
			# Create a new resource for the given endpoint.
			def self.open(endpoint = self::ENDPOINT, **options)
				if endpoint.is_a?(String)
					endpoint = Async::HTTP::Endpoint.parse(endpoint)
				end
				
				client, reference = connect(endpoint)
				
				resource = self.new(client, reference, **options)
				
				return resource unless block_given?
				
				Sync do
					yield resource
				ensure
					resource.close
				end
			end
			
			def self.with(parent, headers: {}, **options)
				reference = parent.reference.with(**options)
				headers = parent.headers.merge(headers)
				
				self.new(parent.delegate, reference, headers)
			end
			
			# @parameter delegate [Async::HTTP::Middleware] the delegate that will handle requests.
			# @parameter reference [::Protocol::HTTP::Reference] the resource identifier (base request path/parameters).
			# @parameter headers [::Protocol::HTTP::Headers] the default headers that will be supplied with the request.
			def initialize(delegate, reference = ::Protocol::HTTP::Reference.parse, headers = ::Protocol::HTTP::Headers.new)
				super(delegate)
				
				@reference = reference
				@headers = headers
			end
			
			attr :reference
			attr :headers
			
			def with(**options)
				self.class.with(self, **options)
			end
			
			def inspect
				"\#<#{self.class} #{@reference.inspect} #{@headers.inspect}>"
			end
			
			def to_s
				"\#<#{self.class} #{@reference.to_s}>"
			end
			
			def call(request)
				request.path = @reference.with(path: request.path).to_s
				request.headers = @headers.merge(request.headers)
				
				super
			end
		end
	end
end
