# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

require "json"

require "protocol/http/body/wrapper"
require "protocol/http/body/buffered"

require_relative "generic"

module Async
	module REST
		module Wrapper
			class URLEncoded < Generic
				APPLICATION_FORM_URLENCODED = "application/x-www-form-urlencoded".freeze
				
				def initialize(content_type = APPLICATION_FORM_URLENCODED)
					@content_type = content_type
				end
				
				attr :content_type
				
				def split(*arguments)
					@content_type.split
				end
				
				def prepare_request(request, payload)
					request.headers["accept"] ||= @content_type
					
					if payload
						request.headers["content-type"] = @content_type
						
						request.body = ::Protocol::HTTP::Body::Buffered.new([
							::Protocol::HTTP::URL.encode(payload)
						])
					end
				end
				
				class Parser < ::Protocol::HTTP::Body::Wrapper
					def join
						::Protocol::HTTP::URL.decode(super, symbolize_keys: true)
					end
				end
				
				def parser_for(response)
					if content_type = response.headers["content-type"]
						if content_type.start_with? @content_type
							return Parser
						end
					end
					
					return super
				end
			end
		end
	end
end
