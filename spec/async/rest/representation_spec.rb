# frozen_string_literal: true

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

require 'async/rest/representation'

RSpec.describe Async::REST::Representation do
	let(:base) {Class.new(described_class)}
	let(:representation_class) {base[Async::REST::Wrapper::JSON]}
	
	describe '.[]' do
		it "uses specified base class" do
			expect(representation_class::WRAPPER).to be Async::REST::Wrapper::JSON
			expect(representation_class.superclass).to be base
		end
	end
	
	describe '#with' do
		let(:resource) {Async::REST::Resource.new(nil)}
		subject {described_class.new(resource)}
		
		it "uses specified base class wrapper" do
			expect(resource).to receive(:with).and_call_original
			representation = subject.with(representation_class)
			
			expect(representation.wrapper).to be_kind_of Async::REST::Wrapper::JSON
		end
	end
end
