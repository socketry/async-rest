#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require 'async'
require 'async/rest'
require 'async/rest/wrapper/form'

require 'date'

URL = "https://api.github.com"
ENDPOINT = Async::HTTP::Endpoint.parse(URL)

module GitHub
	class Wrapper < Async::REST::Wrapper::Form
		DEFAULT_CONTENT_TYPES = {
			"application/vnd.github.v3+json" => Async::REST::Wrapper::JSON::Parser
		}
		
		def initialize
			super(DEFAULT_CONTENT_TYPES)
		end
		
		def parser_for(response)
			if content_type = response.headers['content-type']
				if content_type.start_with? "application/json"
					return Async::REST::Wrapper::JSON::Parser
				end
			end
			
			return super
		end
	end
	
	class Representation < Async::REST::Representation[Wrapper]
	end
	
	class User < Representation
	end
	
	class Client < Representation
		def user(name)
			self.with(User, path: "users/#{name}")
		end
	end
	
	module Paginate
		include Enumerable
		
		def represent(metadata, attributes)
			resource = @resource.with(path: attributes[:id])
			
			representation.new(resource, metadata: metadata, value: attributes)
		end
		
		def each(page: 1, per_page: 50, **parameters)
			return to_enum(:each, page: page, per_page: per_page, **parameters) unless block_given?
			
			while true
				items = @resource.get(self.class, page: page, per_page: per_page, **parameters)
				
				break if items.empty?
				
				Array(items.value).each do |item|
					yield represent(items.metadata, item)
				end
				
				page += 1
				
				# Was this the last page?
				break if items.value.size < per_page
			end
		end
		
		def empty?
			self.value.empty?
		end
	end
	
	class Event < Representation
		def created_at
			DateTime.parse(value[:created_at])
		end
	end
	
	class Events < Representation
		include Paginate
		
		def representation
			Event
		end
	end
	
	class User < Representation
		def public_events
			self.with(Events, path: "events/public")
		end
	end
end

puts "Connecting..."
headers = Protocol::HTTP::Headers.new
headers['user-agent'] = "async-rest/GitHub v#{Async::REST::VERSION}"

GitHub::Client.for(ENDPOINT, headers) do |client|
	user = client.user("ioquatix")
	
	events = user.public_events.to_a
	pp events.first.created_at
	pp events.last.created_at
end

puts "done"
