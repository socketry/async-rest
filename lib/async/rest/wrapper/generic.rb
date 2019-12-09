# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
