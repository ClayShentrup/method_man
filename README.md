# Method Man

Defines a MethodObject class which implements Kent Beck's "[method object](http://c2.com/cgi/wiki?MethodObject)".

## Example

```ruby
  MakeArbitraryArray = MethodObject.new do
    def call(name, age = 21, &test_block)
      [shortname, age, yield(1), test_value] 
    end
    
    private
    
    def shortname
      # all passed (not optional default) arguments in the
      # signature for call() are available as instance methods
      name.slice(0,4).upcase
    end
    
    def test_block_value
      # block is available to be called by name
      test_block.call(2)
    end
  end
  
  MakeArbitraryArray.call('Elliot') { |input| input + 1 }
  => ["ELLI", 21, 2, 3]
```
