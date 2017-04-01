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

## p.50 Add, LessThan のチェック

```ruby
Add.new(Variable.new(:x), Number.new(1)).to_ruby
# => "-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }"
LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby
# => "-> e { (-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) }).call(e) < ↵ (-> e { 3 }).call(e) }"
```


## p.50 人間の限界
最終的に得られる表示は複雑なので、それが正しいかどうかを目で見て判断するのは困難。
次のようにして確かめよう。

```Ruby
environment = { x: 3 }
# => {:x=>3}
proc = eval(Add.new(Variable.new(:x), Number.new(1)).to_ruby)
# => #<Proc (lambda)>
proc.call(environment)
# => 4
proc = eval(LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby )
# => #<Proc (lambda)>
proc.call(environment)
# => false
```

## p.51 Assign
```Ruby
statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1)))
# => «y = x + 1»
statement.to_ruby
# => "-> e { e.merge({ :y => (-> e { (-> e { e[:x] }).call(e) + (-> e { 1 }).call(e) })↵ .call(e) }) }"
proc = eval(statement.to_ruby)
=> #<Proc (lambda)>
proc.call({ x: 3 })
=> {:x=>3, :y=>4}
```
