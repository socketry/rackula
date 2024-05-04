# Getting Started

This guide will show you how to use the `rakula` gem to create a simple static website.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add rackula
~~~

and make sure `wget` is also installed, using your system package manager.

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
