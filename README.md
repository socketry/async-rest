# Async::REST

Roy Thomas Fielding's thesis [Architectural Styles and the Design of Network-based Software Architectures](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) describes [Representational State Transfer](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm) which comprises several core concepts:

- `Resource`: A conceptual mapping to one or more entities.
- `Representation`: An instance of a resource at a given point in time.

This gem models these abstractions as closely and practically as possible and serves as a basis for building asynchronous web clients.

[![Build Status](https://secure.travis-ci.org/socketry/async-rest.svg)](http://travis-ci.org/socketry/async-rest)
[![Code Climate](https://codeclimate.com/github/socketry/async-rest.svg)](https://codeclimate.com/github/socketry/async-rest)
[![Coverage Status](https://coveralls.io/repos/socketry/async-rest/badge.svg)](https://coveralls.io/r/socketry/async-rest)

[async]: https://github.com/socketry/async
[async-io]: https://github.com/socketry/async-io
[falcon]: https://github.com/socketry/falcon

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-rest'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install async-rest

## Usage

Generally speaking, you want to create a representation class for each endpoint. This class is responsible for negotiating content type and processing the response, and traversing related endpoints.

### DNS over HTTP

This simple example shows how to use a custom representation to access DNS over HTTP.

```ruby
require 'async/http/server'
require 'async/http/endpoint'

require 'async/rest/resource'
require 'async/rest/representation'

module DNS
	class Query < Async::REST::Representation
		def initialize(*args)
			# This is the old/weird content-type used by Google's DNS resolver. It's obsolete.
			super(*args, wrapper: Async::REST::Wrapper::JSON.new("application/x-javascript"))
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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
