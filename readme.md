# Rackula

Rackula will immortalize your rackup web app by generating a static copy. It can be used to generate a static site from any rack-compatible middleware (e.g. rails, sinatra, utopia).

[![Development Status](https://github.com/socketry/rackula/workflows/Test/badge.svg)](https://github.com/socketry/rackula/actions?workflow=Test)

## Installation

Install the gem:

    $ gem install rackula

Ensure that `wget` is installed and available.

## Usage

### Rack Applications

In the root directory, simply run `rackula`. It will generate a static site in `static`. For more details about how to change the default behavior, run `rackula --help`.

### Rails Applications

Add a `config.ru` file to your rails app and follow the above instructions.

``` ruby
# config.ru for rails app
require_relative 'config/environment'
run Rails.application
```

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
