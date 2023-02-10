# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

require_relative 'json'
require_relative 'url_encoded'

module Async
	module REST
		module Wrapper
			class Form < Generic
				DEFAULT_CONTENT_TYPES = {
					JSON::APPLICATION_JSON => JSON::Parser,
					URLEncoded::APPLICATION_FORM_URLENCODED => URLEncoded::Parser,
				}
				
				def initialize(content_types = DEFAULT_CONTENT_TYPES)
					@content_types = content_types
				end
				
				def prepare_request(payload, headers)
					@content_types.each_key do |key|
						headers.add('accept', key)
					end
					
					if payload
						headers['content-type'] = URLEncoded::APPLICATION_FORM_URLENCODED
						
						::Protocol::HTTP::Body::Buffered.new([
							::Protocol::HTTP::URL.encode(payload)
						])
					end
				end
				
				def parser_for(response)
					if content_type = response.headers['content-type']
						if parser = @content_types[content_type]
							return parser
						end
					end
					
					return super
				end
			end
		end
	end
end
