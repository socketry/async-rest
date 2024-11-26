# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023-2024, by Samuel Williams.

require "async/rest/a_wrapper"
require "async/rest/wrapper/generic"

describe Async::REST::Wrapper::Generic do
	let(:wrapper) {subject.new}
	
	with "#retry_after_duration" do
		it "can parse integer" do
			expect(wrapper.retry_after_duration("123")).to be == 123
		end
		
		it "can parse date in the past" do
			date = Time.now
			
			# Technically, this should always be in the past:
			expect(wrapper.retry_after_duration(date.httpdate)).to be == 0.0
		end
		
		it "can parse date in the future" do
			date = Time.now + 60
			
			expect(wrapper.retry_after_duration(date.httpdate)).to be > 0.0
		end
	end
end
