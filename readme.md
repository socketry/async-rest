# Async::REST

Roy Thomas Fielding's thesis [Architectural Styles and the Design of Network-based Software Architectures](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm) describes [Representational State Transfer](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm) which comprises several core concepts:

  - `Resource`: A conceptual mapping to one or more entities.
  - `Representation`: An instance of a resource at a given point in time.

This gem models these abstractions as closely and practically as possible and serves as a basis for building asynchronous web clients.

[![Development Status](https://github.com/socketry/async-rest/workflows/Test/badge.svg)](https://github.com/socketry/async-rest/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/async-rest/) for more details.

  - [Getting Started](https://socketry.github.io/async-rest/guides/getting-started/index) - This guide explains the design of the `async-rest` gem and how to use it to access RESTful APIs.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

This project uses the [Developer Certificate of Origin](https://developercertificate.org/). All contributors to this project must agree to this document to have their contributions accepted.

### Contributor Covenant

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/). All contributors and participants agree to abide by its terms.
