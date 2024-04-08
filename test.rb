#!/usr/bin/env ruby

require 'async/rest'

module Ollama
	class Generate < Async::REST::Representation[Async::REST::Wrapper::JSON]
		def question
			value[:Question]
		end
		
		def answer
			value[:Answer]
		end
	end
	
	class Client < Async::REST::Resource
		ENDPOINT = Async::HTTP::Endpoint.parse('http://localhost:11434')
		
		def generate(prompt, **options)
			options[:model] ||= 'llama2:13b'
			options[:stream] = false
			
			Generate.post(self.with(path: '/api/generate'), options)
		end
	end
end

Ollama::Client.open do |client|
	reply = client.generate("Hello")
	
	puts reply.inspect
end
