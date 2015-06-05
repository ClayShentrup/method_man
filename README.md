# Method Man

Defines a MethodObject class which facilitates basic setup for Kent Beck's "[method object](http://c2.com/cgi/wiki?MethodObject)".

The MethodObject class is largely based on a Ruby Struct, but with a few additional features:

* Facilitates basic method object pattern setup. You only need to supply an instance `call` method.
* Accepts a list of arguments which are mapped to required keyword arguments.
* Disallows calling `new` on the resulting MethodObject class instance.

## Bundler usage

```ruby
gem 'method_man', require: 'method_object'
```

## Requirements
* Ruby >= 2.1

## Example

```ruby
  require 'method_object'

  MakeArbitraryArray = MethodObject.new(:first_name, :last_name, :message) do
    def call
      [fullname, message, 42]
    end

    private

    def fullname
      "#{first_name} #{last_name}"
    end
  end

  MakeArbitraryArray.call(
    first_name: 'John',
    last_name: 'Smith',
    message: 'Hi',
  )
  => ["John Smith", 'Hi', 42]
```
