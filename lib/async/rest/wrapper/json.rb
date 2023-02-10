# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require 'json'

require 'protocol/http/body/wrapper'
require 'protocol/http/body/buffered'

require_relative 'generic'

module Async
	module REST
		module Wrapper
			class JSON < Generic
				APPLICATION_JSON = "application/json".freeze
				APPLICATION_JSON_STREAM = "application/json; boundary=NL".freeze
				
				def initialize(content_type = APPLICATION_JSON)
					@content_type = content_type
				end
				
				attr :content_type
				
				def split(*arguments)
					@content_type.split
				end
				
				def prepare_request(payload, headers)
					headers['accept'] ||= @content_type
					
					if payload
						headers['content-type'] = @content_type
						
						HTTP::Body::Buffered.new([
							::JSON.dump(payload)
						])
					end
				end
				
				class Parser < HTTP::Body::Wrapper
					def join
						::JSON.parse(super, symbolize_names: true)
					end
				end
				
				def parser_for(response)
					if content_type = response.headers['content-type']
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
