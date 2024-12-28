# Getting Started

This guide explains the design of the `async-rest` gem and how to use it to access RESTful APIs.

## Installation

Add the gem to your project:

``` shell
$ bundle add async-rest
```

## Core Concepts

The `async-rest` gem has two core concepts:

- A {ruby Async::REST::Resource} instance represents a specific resource and a delegate (HTTP connection) for accessing that resource.
- A {ruby Async::REST::Representation} instance represents a specific representation of a resource - usually a specific request to a URL that returns a response with a given content type.

Just as a webpage has hyperlinks, forms and buttons for connecting information and performing actions, a representation may also carry associated links to actions that can be performed on a resource. However, many services define a fixed set of actions that can be performed on a given resource using a schema. As such, the `async-rest` gem does not have a standard mechanism for discovering actions on a resource at runtime (or follow a design that requires this).

## Usage

Generally speaking, you should model your interface around representations. Each representation should be a subclass of {ruby Async::REST::Representation} and define methods that represent the actions that can be performed on that resource.

```ruby
require 'async/rest'

module DNS
  class Query < Async::REST::Representation[Async::REST::Wrapper::JSON]
    def question
      value[:Question]
    end

    def answer
      value[:Answer]
    end
  end

  class Client < Async::REST::Resource
    # This is the default endpoint to use unless otherwise specified:
    ENDPOINT = Async::HTTP::Endpoint.parse('https://dns.google/resolve')

    # Resolve a DNS query.
    def resolve(name, type)
      Query.get(self.with(parameters: { name: name, type: type }))
    end
  end
end

DNS::Client.open do |client|
  query = client.resolve('example.com', 'AAAA')

  puts query.question
  # {:name=>"example.com.", :type=>28}
  puts query.answer
  # {:name=>"example.com.", :type=>28, :TTL=>13108, :data=>"2606:2800:220:1:248:1893:25c8:1946"}
end
```

It should be noted that the above client is not a representation, but a resource. That is because `https://dns.google.com/resolve` is a fixed endpoint that does not have a schema for discovering actions at runtime. The `resolve` method is a convenience method that creates a new representation and performs a GET request to the endpoint.