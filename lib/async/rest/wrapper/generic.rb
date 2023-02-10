# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2023, by Samuel Williams.

module Async
	module REST
		module Wrapper
			class Generic
				# @param payload [Object] a request payload to send.
				# @param headers [Protocol::HTTP::Headers] the mutable HTTP headers for the request.
				# @return [Body | nil] an optional request body based on the given payload.
				def prepare_request(payload, headers)
				end
				
				# @param request [Protocol::HTTP::Request] the request that was made.
				# @param response [Protocol::HTTP::Response] the response that was received.
				# @return [Object] some application specific representation of the response.
				def process_response(request, response)
					wrap_response(response)
				end
				
				def parser_for(response)
					# It's not always clear why this error is being thrown.
					return Unsupported
				end
				
				# Wrap the response body in the given klass.
				def wrap_response(response)
					if body = response.body
						response.body = parser_for(response).new(body)
					end
					
					return response
				end
				
				class Unsupported < HTTP::Body::Wrapper
					def join
						raise UnsupportedError, super
					end
				end
			end
		end
	end
end
