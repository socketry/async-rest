#!/usr/bin/env ruby

require_relative '../../lib/async/rest'
require_relative '../../lib/async/rest/wrapper/url_encoded'

require 'nokogiri'

Async.logger.debug!

module XKCD
	module Wrapper
		# This defines how we interact with the XKCD service.
		class HTML < Async::REST::Wrapper::URLEncoded
			TEXT_HTML = "text/html"
			
			# How to process the response body.
			class Parser < ::Protocol::HTTP::Body::Wrapper
				def join
					Nokogiri::HTML(super)
				end
			end
			
			# We wrap the response body with the parser (it could incrementally parse the body).
			def wrap_response(response)
				if body = response.body
					response.body = Parser.new(body)
				end
			end
			
			def process_response(request, response)
				if content_type = response.headers['content-type']
					if content_type.start_with? TEXT_HTML
						wrap_response(response)
					else
						raise Error, "Unknown content type: #{content_type}!"
					end
				end
				
				return response
			end
		end
	end
	
	# A comic representation.
	class Comic < Async::REST::Representation[Wrapper::HTML]
		def image_url
			self.value.css("#comic img").attribute("src").text
		end
	end
end

Async do
	URL = 'https://xkcd.com/2205/'
	Async::REST::Resource.for(URL) do |resource|
		representation = resource.get(XKCD::Comic)
		
		p	representation.image_url
	end
end
