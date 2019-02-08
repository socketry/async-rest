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

require 'async/http/server'
require 'async/http/url_endpoint'
require 'async/rest/resource'

RSpec.shared_examples_for Async::REST::Wrapper do
	include_context Async::RSpec::Reactor
	
	let(:url) {'http://127.0.0.1:9296/'}
	
	let(:representation) {Async::REST::Representation.for(url, wrapper: subject)}
	let(:endpoint) {Async::HTTP::URLEndpoint.parse(url)}
	
	let(:server) do
		Async::HTTP::Server.for(endpoint) do |request|
			if request.headers['content-type'] == subject.content_type
				# Echo it back:
				Async::HTTP::Response[200, request.headers, request.body]
			end
		end
	end
	
	let!(:server_task) do
		reactor.async do
			server.run
		end
	end
	
	let(:payload) {{username: "Frederick", password: "Fish"}}
	
	it "can post payload representation" do
		response = representation.post(payload)
		
		expect(response).to be_success
		expect(response.read).to be == payload
		
		server_task.stop
		representation.close
	end
end
