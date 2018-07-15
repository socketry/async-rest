# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'json'

module Async
	module REST
		module Wrapper
			class JSON
				CONTENT_TYPE = "application/json".freeze
				
				def initialize(content_type = CONTENT_TYPE)
					@content_type = content_type
				end
				
				def split(*args)
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
				
				def process_response(response)
					# We expect all responses to be valid JSON.
					# I tried inspecting content-type, but too many servers do the wrong thing.
					if body = response.body
						response.body = Parser.new(body)
					end
					
					return response
				end
				
				class Parser < HTTP::Body::Wrapper
					def join
						::JSON.parse(super, symbolize_names: true)
					end
				end
			end
		end
	end
end
