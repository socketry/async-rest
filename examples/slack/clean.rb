#!/usr/bin/env ruby

require 'pry'
require 'set'

def rate_limited?(response)
	pp response
	
	response[:error] == "ratelimited"
end

require 'async/rest'

URL = "https://slack.com/api"
TOKEN = "xoxp-your-api-token"

Async::REST::Resource.for(URL) do |resource|
	authenticated = resource.with(parameters: {token: TOKEN})
	delete = authenticated.with(path: "chat.delete")
	
	page = 1
	while true
		search = authenticated.with(path: "search.messages", parameters: {page: page, count: 100, query: "from:@username before:2019-02-15"})
		representation = search.get
		
		messages = representation.value[:messages]
		matches = messages[:matches]
		
		puts "Found #{matches.count} messages on page #{page} out of #{messages[:total]}..."
		
		break if matches.empty?
		
		matches.each do |message|
			text = message[:text]
			channel_id = message[:channel][:id]
			channel_name = message[:channel][:name]
			timestamp = message[:ts]
		
			pp [timestamp, channel_name, text]
		
			message_delete = Async::REST::Representation.new(
				delete.with(parameters: {channel: channel_id, ts: timestamp})
			)
		
			response = message_delete.post
			if rate_limited?(response.read)
				puts "Rate limiting..."
				Async::Task.current.sleep 10
			end
		end
		
		page += 1
	end
end

puts "Done"
