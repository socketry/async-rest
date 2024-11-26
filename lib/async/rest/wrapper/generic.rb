# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2024, by Samuel Williams.

module Async
	module REST
		module Wrapper
			class Generic
				def retry_after_duration(value)
					retry_after_time = Time.httpdate(value)
					return [retry_after_time - Time.now, 0].max
				rescue ArgumentError
					return value.to_f
				end
				
				def response_for(resource, request)
					while true
						response = resource.call(request)
						
						if response.status == 429
							if retry_after = response.headers["retry-after"]
								sleep(retry_after_duration(retry_after))
							else
								# Without the `retry-after` header, we can't determine how long to wait, so we just return the response.
								return response
							end
						else
							return response
						end
					end
				end
				
				def call(resource, method = "GET", payload = nil, &block)
					request = ::Protocol::HTTP::Request[method, nil]
					
					self.prepare_request(request, payload)
					
					response = self.response_for(resource, request)
					
					# If we exit this block because of an exception, we close the response. This ensures we don't have any dangling connections.
					begin
						self.process_response(request, response)
						
						yield response
					rescue
						response.close
						
						raise
					end
				end
				
				# @param payload [Object] a request payload to send.
				# @param headers [Protocol::HTTP::Headers] the mutable HTTP headers for the request.
				# @return [Body | nil] an optional request body based on the given payload.
				def prepare_request(request, payload)
					request.body = ::Protocol::HTTP::Body::Buffered.wrap(payload)
				end
				
				# @param request [Protocol::HTTP::Request] the request that was made.
				# @param response [Protocol::HTTP::Response] the response that was received.
				# @return [Object] some application specific representation of the response.
				def process_response(request, response)
					wrap_response(response)
				end
				
				def parser_for(response)
					# It's not always clear why this error is being thrown.
					return nil
				end
				
				# Wrap the response body in the given klass.
				def wrap_response(response)
					if body = response.body
						if parser = parser_for(response)
							response.body = parser.new(body)
						end
					end
					
					return response
				end
				
				class Unsupported < ::Protocol::HTTP::Body::Wrapper
					def join
						raise UnsupportedError, super
					end
				end
			end
		end
	end
end
