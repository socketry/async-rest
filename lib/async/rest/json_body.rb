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
		class JSONBody
			def self.wrap_request(headers, payload)
				headers['accept'] = 'application/json;q=0.9, */*;q=0.8'
				
				if payload
					headers['content-type'] = 'application/json'
					
					return [JSON.dump(payload)]
				end
			end
			
			def self.wrap_response(response)
				if content_type = response.headers['content-type']
					if content_type.start_with? 'application/json'
						response.body = self.new(response.body)
					end
				end
			end
			
			def initialize(body)
				@body = body
			end
			
			def close
				@body = @body.close
				
				return self
			end
			
			def join
				JSON.parse(@body.join, symbolize_names: true)
			end
			
			def finished?
				@body.finished?
			end
		end
	end
end
