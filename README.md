Key Decisions

* Services use resolve
* Services are internal services to the application
* Services require a search path
* user defined services should be a bunch of modules
* services modules must be defined in a file with a corresponding name, eg: `PhotoServices` => `photo_services.rb`
* modules with a name ending in `PermissionsServices` are a special case and are assumed to contain permission predicates
* permissions predicates end in a `?` and have the same arity as the protected service method

Limitations

* currently it is assumed the application is a Rails application and services modules are search for in `app/services`. To override this behaviour, reimplement `Services::Container`


# Services

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'railsservices'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install railsservices

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
