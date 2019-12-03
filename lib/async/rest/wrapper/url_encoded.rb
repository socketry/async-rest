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

require 'protocol/http/body/wrapper'
require 'protocol/http/body/buffered'

require_relative 'generic'

module Async
	module REST
		module Wrapper
			class URLEncoded < Generic
				APPLICATION_FORM_URLENCODED = "application/x-www-form-urlencoded".freeze
				
				def initialize(content_type = APPLICATION_FORM_URLENCODED)
					@content_type = content_type
				end
				
				attr :content_type
				
				def split(*args)
					@content_type.split
				end
				
				def prepare_request(payload, headers)
					headers['accept'] ||= @content_type
					
					if payload
						headers['content-type'] = @content_type
						
						::Protocol::HTTP::Body::Buffered.new([
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
