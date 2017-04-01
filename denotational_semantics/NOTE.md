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

## p.52 While

```ruby
statement = While.new(
  LessThan.new(Variable.new(:x), Number.new(5)),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
)
# => «while (x < 5) { x = x * 3 }»
statement.to_ruby
# => "-> e { while (-> e { (-> e { e[:x] }).call(e) < (-> e { 5 }).call(e) }).call(e); e = (-> e { e.merge({ :x => (-> e { (-> e { e[:x] }).call(e) * (-> e { 3 }).call(e) ↵ }).call(e) }) }).call(e); end; e }"
proc = eval(statement.to_ruby)
# => #<Proc (lambda)>
proc.call({ x: 1 })
# => {:x=>9}
```


## [Column] Whileの比較


> The small-step operational semantics of «while» is written as a reduction rule for an abstract machine.
>
> The overall looping behavior isn’t part of the rule’s action reduction just turns a «while» statement into an «if» statement
> but it emerges as a consequence of the future reductions performed by the machine.
>
> To understand what «while» does, we need to look at all of the small-step rules
> and work out how they interact over the course of a SIMPLE program’s execution.

**Small Step 意味論**
```ruby
class While

  def reducible?
    true
  end

  def reduce(environment)
    [
      If.new(condition,
        Sequence.new(body, self),
        DoNothing.new
      ),
      environment
    ]
  end
end

```

---

> «while»’s big-step operational semantics is written as an evaluation rule that shows how to compute the final environment directly.
> The rule contains a recursive call to itself, so there’s an explicit indication that «while» will cause a loop during evaluation,
> but it’s not quite the kind of loop that a SIMPLE programmer would recognize.
>
> Big-step rules are written in a recursive style, describing the complete evaluation
> of an expression or statement in terms of the evaluation of other pieces of syntax,
> so this rule tells us that the result of evaluating a «while» statement may depend upon
> the result of evaluating the same statement in a different environment,
> but it requires a leap of intuition to connect this idea with the iterative behavior that
> «while» is supposed to exhibit.
>
> Fortunately the leap isn’t too large: a bit of mathematical reasoning can show that
> the two kinds of loop are equivalent in principle, and when the metalanguage supports
> tail call optimization, they’re also equivalent in practice.

**Big Step 意味論**
```ruby
class While # args = {:condition, :body}
  def evaluate(environment)
    case condition.evaluate(environment)
    when Boolean.new(true)
      evaluate(body.evaluate(environment))
    when Boolean.new(false)
      environment
    end
  end
end
```

---

> The denotational semantics of «while» shows how to rewrite it in Ruby,
> namely by using Ruby’s while keyword.
>
> This is a much more direct translation: Ruby has native support for iterative loops,
> and the denotation rule shows that «while» can be implemented with that feature.
>
> There’s no leap required to understand how the two kinds of loop relate to each other,
> so if we understand how Ruby while loops work, we understand SIMPLE «while» loops too.
>
> Of course, this means we’ve just converted the problem of understanding SIMPLE into
> the problem of understanding the denotation language, which is a serious disadvantage when
> that language is as large and ill-specified as Ruby, but it becomes an advantage when
> we have a small mathematical language for writing denotations.

** 表示的 意味論**
```ruby
class While
  def to_ruby
    to_lambda_str %W(
      while (#{condition.to_ruby}).call(e);
        e = (#{body.to_ruby}).call(e);
      end;
      e
    )
  end
end
```
