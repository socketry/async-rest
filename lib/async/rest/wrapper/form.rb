# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.
# Copyright, 2025, by Ayush Newatia.

require_relative "json"
require_relative "url_encoded"

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
				
				def prepare_request(request, payload)
					@content_types.each_key do |key|
						request.headers.add("accept", key)
					end
					
					if payload
						request.headers["content-type"] = URLEncoded::APPLICATION_FORM_URLENCODED
						
						request.body = ::Protocol::HTTP::Body::Buffered.new([
							::Protocol::HTTP::URL.encode(payload)
						])
					end
				end
				
				def parser_for(response)
					media_type, _ = response.headers["content-type"].split(";")
					if media_type && parser = @content_types[media_type]
						return parser
					end
					
					return super
				end
			end
		end
	end
end
