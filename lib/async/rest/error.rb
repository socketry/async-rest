# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Async
	module REST
		class Error < StandardError
		end
		
		class RequestError < Error
		end
		
		class UnsupportedError < Error
		end
		
		class ResponseError < Error
			def initialize(response)
				super(response.read)
				
				@response = response
			end
			
			def to_s
				"#{@response}: #{super}"
			end
			
			attr :response
		end
	end
end
