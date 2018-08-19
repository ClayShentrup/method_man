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

Why is the class method called `call`? Some people have argued for names like `TaskSender.send_task` instead of `TaskSender.call`. My reasoning is.

1. `call` is a ubiquitous concept in Ruby, as it's how you invoke `Procs`.
2. There's even a syntactic sugar for this, `.()` instead of `.call()`, e.g. `TaskSender.(task)`.
3. The name `call` clearly _calls_ out to someone reading the code that "this is an invocation of a method object". I would say this is especially so if you see something like `TaskSender.(task)`.
4. Avoiding redundancy. Any custom name will always just match the module/class name, e.g.
```ruby
TaskSender.send_task # This is redundant
```
5. Minimizing complexity: adding an option to specify the class method would introduce additional complexity.

### History
In [Refactoring: Ruby Edition](http://www.informit.com/store/refactoring-ruby-edition-9780321603500), we see this at the top of the section on the method object pattern.

> Stolen shamelessly from Kent Beck’s Smalltalk Best Practices.
> 1. Create a new class, name it after the method.

In the example, the instance method `Account#gamma` is refactored to `Gamma.compute`. Kent Beck's original example refactored `Obligation#sendTask` to `TaskSender.compute`.

### Noun vs. verb

Beck uses `TaskSender`. I personally prefer `SendTask`, essentially just preserving the name of whatever method you're converting to a method object. However I don't think this detail is of much import. I might recommend trying a little of both, and seeing which naming seems least confusing when you're coming back to it weeks later.

## How useful is this pattern?
Kent Beck has [raved about it](https://twitter.com/kentbeck/status/195168291134783489), saying:

> extract method object is such deep deep magic. it brings clarity to the confused and structure to the chaotic.
