# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'async/rest/resource'

describe Async::REST::Resource do
	let(:url) {'http://example.com'}
	let(:resource) {subject.for(url)}
	
	it 'can update path' do
		expect(resource.reference.path).to be == '/'
		
		foo_resource = resource.with(path: '/foo')
		expect(foo_resource.reference.path).to be == '/foo'
		
		bar_resource = foo_resource.with(path: 'bar')
		expect(bar_resource.reference.path).to be == '/foo/bar'
	end
end
