# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require 'async/rest/representation'

describe Async::REST::Representation do
	let(:base) {Class.new(subject)}
	let(:representation_class) {base[Async::REST::Wrapper::JSON]}
	
	with '.[]' do
		it "uses specified base class" do
			expect(representation_class::WRAPPER).to be_a(Async::REST::Wrapper::JSON)
			expect(representation_class.superclass).to be_equal(base)
		end
	end
	
	with '.for' do
		let(:resource) {Async::REST::Resource.new(nil)}
		let(:response) {Protocol::HTTP::Response[200, {}, nil]}
		
		it "can construct a representation" do
			expect(response).to receive(:read).and_return({test: 123})
			expect(response).to receive(:headers).and_return({test: 456})
			
			expect(representation_class).to receive(:new)
			representation = representation_class.for(resource, response)
			
			expect(representation.value).to be == {test: 123}
			expect(representation.metadata).to be == {test: 456}
		end
		
		it "can construct a representation with a block" do
			expect(representation_class).not.to receive(:new)
			
			representation = representation_class.for(resource, response) do |resource, response|
				[resource, response]
			end
			
			expect(representation).to be == [resource, response]
		end
	end
	
	with '#with' do
		let(:resource) {Async::REST::Resource.new(nil)}
		let(:representation) {subject.new(resource)}
		
		it "uses specified base class wrapper" do
			expect(resource).to receive(:with)
			custom_representation = representation.with(representation_class)
			
			expect(custom_representation).to be_a representation_class
		end
	end
end
