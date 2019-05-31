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
require 'async/http/endpoint'
require 'async/rest/resource'

RSpec.describe Async::REST::Resource do
	include_context Async::RSpec::Reactor
	
	let(:url) {'http://127.0.0.1:9295'}
	subject{described_class.for(url)}
	
	let(:endpoint) {Async::HTTP::Endpoint.parse(url)}
	let(:body) {Async::HTTP::Body::Buffered.new(['{"foo": "bar"}'])}
	
	it "can get resource" do
		server = Async::HTTP::Server.for(endpoint) do |request|
			Protocol::HTTP::Response[
				200,
				{'content-type' => 'application/json'},
				body
			]
		end
		
		server_task = reactor.async do
			server.run
		end
		
		representation = subject.get
		expect(representation.value).to be == {foo: 'bar'}
		
		server_task.stop
		subject.close
	end
	
	it "can get compressed resource" do
		server = Async::HTTP::Server.for(endpoint) do |request|
			Protocol::HTTP::Response[
				200,
				{'content-type' => 'application/json', 'content-encoding' => 'gzip'},
				Protocol::HTTP::Body::Deflate.for(body)
			]
		end
		
		server_task = reactor.async do
			server.run
		end
		
		representation = subject.get
		expect(representation.metadata).to_not include('content-encoding')
		expect(representation.value).to be == {foo: 'bar'}
		
		server_task.stop
		subject.close
	end
	
	it "can compute nested path" do
		user = subject.with(path: "users/5")
		expect(user.reference.path).to be == "/users/5"
	end
end
