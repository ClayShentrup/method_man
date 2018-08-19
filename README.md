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

## Naming

In [Refactoring: Ruby Edition](http://www.informit.com/store/refactoring-ruby-edition-9780321603500), we see this at the top of the section on the method object pattern.

> Stolen shamelessly from Kent Beck’s Smalltalk Best Practices.
> 1. Create a new class, name it after the method.

In the example, the instance method `Account#gamma` is refactored to `Gamma.compute`. Kent Beck's original example refactored `Obligation#sendTask` to `TaskSender.compute`. In both cases, the new method has a generic name, `compute`, because it would be redundant to name it, given the class name should already clearly describe the purpose of the original method. For instance:

```ruby
TaskSender.send_task # This is redundant.
```

A generic name also more clearly indicates that this is a method object, which only has one function and shouldn't generally contain additional class methods.

In the case of this gem, there's also a simple practical consideration: calling `call` by convention is simpler than requiring configuration of the specific method name.

Why `call` instead of `compute`? Because in Ruby, we use `call` to invoke `Proc` objects, so it's consistent with analogous constructs in the language.

### Noun vs. verb

Beck uses `TaskSender`. I personally prefer `SendTask`, essentially just preserving the name of whatever method you're converting to a method object. I don't think detail is of much import.

## How useful is this pattern?
Kent Beck has [raved about it](https://twitter.com/kentbeck/status/195168291134783489), saying:

> extract method object is such deep deep magic. it brings clarity to the confused and structure to the chaotic.
