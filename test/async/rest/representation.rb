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
