# Releases

## v0.20.0

  - Migrated to `protocol-url` gem for URL handling.
  - Ensured instances are properly closed after use to prevent resource leaks.
  - All wrappers are now required by default from main `async/rest.rb` entry point.
  - Fixed logic to correctly parse JSON responses in `Form` wrapper.

## v0.19.1

  - Fixed `retry-after` header handling to treat it as a single value header.

## v0.19.0

  - Added support for standard `retry-after` rate limiting.
  - Improved response body handling to only replace the body if a parser is found.

## v0.18.0

  - Minor improvements and fixes to `Mutable`.

## v0.17.0

  - Bug fixes and minor improvements.

## v0.16.0

  - Removed legacy behaviour for cleaner implementation.

## v0.15.0

  - `Representation.for` can now take a block and return a custom representation.
  - Renamed methods to prefer `method` rather than `verb` for HTTP operations.

## v0.14.0

  - Fixed constant names.
  - Removed unused and legacy requires.

## v0.13.0

  - Better support for streaming responses.
  - Simplified interface for resources and representations.

## v0.12.4

  - Fixed `self.new` to use `self.class.new` for proper subclass instantiation.

## v0.12.3

  - Ensured correct wrapper class is used when making derived representations.
  - Improved argument handling with `*arguments` syntax.

## v0.12.2

  - Fixed adding composite headers.

## v0.12.1

  - Improved error handling to raise a response error if the response was non-200 status.
  - Better overall error handling throughout the library.

## v0.12.0

  - Added `Form` wrapper which behaves like a standard HTML form.
  - Improved error handling.
  - Added GitHub feed example.
  - Added example showing multiple simultaneous requests.
  - Added example for scraping HTML programmatically.

## v0.10.1

  - Ensured response is closed if it causes an exception.

## v0.10.0

  - Renamed `url` parameter to `endpoint` for clarity (with backwards compatibility).

## v0.9.0

  - Simplified handling of wrapped responses.
  - Improved consistency and flexibility of `Representation`.
  - Added path computation checks.

## v0.8.2

  - Added base `Error` class.
  - Better handling of resource references.

## v0.8.1

  - Updated dependencies.

## v0.8.0

  - Fixed URL usage throughout the library.
  - Updated dependencies.

## v0.7.3

  - Fixed circular loading issue.
  - Increased rate limiting delay.

## v0.7.2

  - Fixed missing `require` for `representation`.

## v0.7.1

  - Relaxed gem dependencies.

## v0.7.0

  - Added support for URL encoded payloads.

## v0.6.0

  - **Breaking**: RESTful design based on Fielding's thesis.

## v0.5.2

  - Fixed bad require statement.

## v0.5.1

  - Simplified sub-resources implementation.

## v0.4.0

  - Updated dependencies.

## v0.3.0

  - Added `@wrapper` instance to handle request and response encoding/decoding logic.
  - Implemented middleware-style JSON serialization/deserialization.
  - Moved compression functionality into `Async::HTTP::Compressor`.

## v0.2.0

  - Added compression support.
  - General code cleanup and improvements.

## v0.1.0

  - Initial release split from `async-http`.
