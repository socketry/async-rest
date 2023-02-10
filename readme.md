# Async::REST

Roy Thomas Fielding's thesis [Architectural Styles and the Design of Network-based Software Architectures](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) describes [Representational State Transfer](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm) which comprises several core concepts:

  - `Resource`: A conceptual mapping to one or more entities.
  - `Representation`: An instance of a resource at a given point in time.

This gem models these abstractions as closely and practically as possible and serves as a basis for building asynchronous web clients.

[![Development Status](https://github.com/socketry/async-rest/workflows/Test/badge.svg)](https://github.com/socketry/async-rest/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'async-rest'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install async-rest

## Usage

Generally speaking, you want to create a representation class for each remote resource. This class is responsible for negotiating content type and processing the response, and traversing related resources.

### DNS over HTTP

This simple example shows how to use a custom representation to access DNS over HTTP.

``` ruby
require 'async/http/server'
require 'async/http/endpoint'

require 'async/rest/resource'
require 'async/rest/representation'

module DNS
	class Query < Async::REST::Representation
		def initialize(*arguments)
			# This is the old/weird content-type used by Google's DNS resolver. It's obsolete.
			super(*arguments, wrapper: Async::REST::Wrapper::JSON.new("application/x-javascript"))
		end
		
		def question
			value[:Question]
		end
		
		def answer
			value[:Answer]
		end
	end
end

URL = 'https://dns.google.com/resolve'
Async::REST::Resource.for(URL) do |resource|
	# Specify the representation class as the first argument (client side negotiation):
	query = resource.get(DNS::Query, name: 'example.com', type: 'AAAA')

	pp query.metadata
	pp query.value
end
```

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.
