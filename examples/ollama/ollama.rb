#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest"
require "console"

terminal = Console::Terminal.for($stdout)
terminal[:reply] = terminal.style(:blue)
terminal[:reset] = terminal.reset

module Ollama
	class Wrapper < Async::REST::Wrapper::Generic
		APPLICATION_JSON = "application/json"
		APPLICATION_JSON_STREAM = "application/x-ndjson"
		
		def prepare_request(request, payload)
			request.headers.add("accept", APPLICATION_JSON)
			request.headers.add("accept", APPLICATION_JSON_STREAM)
			
			if payload
				request.headers["content-type"] = APPLICATION_JSON
				
				request.body = ::Protocol::HTTP::Body::Buffered.new([
					::JSON.dump(payload)
				])
			end
		end
		
		class StreamingResponseParser < ::Protocol::HTTP::Body::Wrapper
			def initialize(...)
				super
				
				@buffer = String.new.b
				@offset = 0
				
				@response = String.new
				@value = {response: @response}
			end
			
			def read
				return if @buffer.nil?
				
				while true
					if index = @buffer.index("\n", @offset)
						line = @buffer.byteslice(@offset, index - @offset)
						@buffer = @buffer.byteslice(index + 1, @buffer.bytesize - index - 1)
						@offset = 0
						
						return ::JSON.parse(line, symbolize_names: true)
					end
					
					if chunk = super
						@buffer << chunk
					else
						return nil if @buffer.empty?
						
						line = @buffer
						@buffer = nil
						@offset = 0
						
						return ::JSON.parse(line, symbolize_names: true)
					end
				end
			end
			
			def each
				super do |line|
					token = line.delete(:response)
					@response << token
					@value.merge!(line)
					
					yield token
				end
			end
			
			def join
				self.each{}
				
				return @value
			end
		end
		
		def parser_for(response)
			case response.headers["content-type"]
			when APPLICATION_JSON
				return Async::REST::Wrapper::JSON::Parser
			when APPLICATION_JSON_STREAM
				return StreamingResponseParser
			end
		end
	end
	
	class Generate < Async::REST::Representation[Wrapper]
		def response
			self.value[:response]
		end
		
		def context
			self.value[:context]
		end
		
		def model
			self.value[:model]
		end
		
		def generate(prompt, &block)
			self.class.post(self.resource, prompt: prompt, context: self.context, model: self.model, &block)
		end
	end
	
	class Client < Async::REST::Resource
		ENDPOINT = Async::HTTP::Endpoint.parse("http://localhost:11434")
		
		def generate(prompt, **options, &block)
			options[:prompt] = prompt
			options[:model] ||= "llama2"
			
			Generate.post(self.with(path: "/api/generate"), options, &block)
		end
	end
end

Ollama::Client.open do |client|
	generator = client
	
	while input = $stdin.gets
		generator = generator.generate(input) do |response|
			terminal.write terminal[:reply]
			
			response.body.each do |token|
				terminal.write token
			end
			
			terminal.puts terminal[:reset]
		end
	end
end
