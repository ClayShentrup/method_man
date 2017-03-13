# Method Man

Defines a MethodObject class which facilitates basic setup for Kent Beck's "[method object](http://c2.com/cgi/wiki?MethodObject)".

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

  class MakeArbitraryArray < MethodObject
    attrs(:first_name, :last_name, :message)

    def call
      [fullname, message, 42]
    end

    def fullname
      "#{first_name} #{last_name}"
    end
  end

  MakeArbitraryArray.call(
    first_name: 'John',
    last_name: 'Smith',
    message: 'Hi',
  )
  => ['John Smith', 'Hi', 42]
```

Also allows automatic delegation inspired by Go's
[delegation](https://nathany.com/good/).


```ruby
  require 'method_object'

  class MakeArbitraryArray < MethodObject
    attrs(:company)

    def call
      [
        company.name,
        name, # Automatic delegation since company has a `name` method
        company_name, # Automatic delegation with prefix
      ]
    end
  end

  company = Company.new(name: 'Tyrell Corporation')

  MakeArbitraryArray.call(company: company)
  => ['Tyrell Corporation', 'Tyrell Corporation', 'Tyrell Corporation']
```
