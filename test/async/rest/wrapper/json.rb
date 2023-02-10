# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require 'wrapper_examples'
require 'async/rest/wrapper/json'

describe Async::REST::Wrapper::JSON do
	let(:wrapper) {subject.new}
	it_behaves_like AWrapper
end
