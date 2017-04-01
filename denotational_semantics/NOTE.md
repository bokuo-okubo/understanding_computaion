## p.47~ Denotational Semantics

## p.48 表示的意味論の最初の挙動チェック

```ruby
Number.new(5).to_ruby
# => "-> e { 5 }"
Boolean.new(false).to_ruby
# => "-> e { false }"
```


## p.49 ドキドキ初めての Kernel#eval

```ruby
proc = eval(Number.new(5).to_ruby)
# => #<Proc (lambda)>
proc.call({})
# => 5
proc = eval(Boolean.new(false).to_ruby)
# => #<Proc (lambda)>
proc.call({})
# => false
```


## p49 Check Variable
```ruby
expression = Variable.new(:x)
# => «x»
expression.to_ruby
# => "-> e { e[:x] }"
proc = eval(expression.to_ruby)
# => #<Proc (lambda)>
proc.call({ x: 7 })
# => 7
```
