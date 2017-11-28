require '../../base_definitions.rb'

def to_lambda_str(_inspect = "e")
  build =-> str { "-> e { #{str} }" }
  case _inspect
  when String
    build[_inspect]
  when Array
    build[_inspect.join("\s")]
  end
end

class Number # args => {:value}
  def to_ruby
    to_lambda_str value.inspect
  end
end

class Boolean
  def to_ruby
    to_lambda_str value.inspect
  end
end

class Variable # args => {:name}

  ##############################################################################
  # expression = Variable.new(:x)
  # # => «x»
  # expression.to_ruby
  # # => "-> e { e[:x] }"
  # proc = eval(expression.to_ruby)
  # # => #<Proc (lambda)>
  # proc.call({ x: 7 })
  # # => 7
  ##############################################################################
  def to_ruby
    to_lambda_str "e[#{name.inspect}]"
  end
end



##### ASTs whitch recieve sub-expression arguments #############################
# We know that each subexpression will be denoted by a proc’s Ruby source,
# so we can use them as part of a larger piece of Ruby source that calls
# those procs with the supplied environment and does some computation
# with their return values.
################################################################################

class Add # args = {:left, :right}
  def to_ruby
    to_lambda_str "(#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e)"
  end
end

class Multiply # args = {:left, :right}
  def to_ruby
    to_lambda_str "(#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e)"
  end
end

class LessThan # args = {:left, :right}
  def to_ruby
    to_lambda_str "(#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e)"
  end
end

# Statements

class Assign # args = {:name, :expression}
  def to_ruby
    to_lambda_str "e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) })"
  end
end

class DoNothing
  def to_ruby
    to_lambda_str
  end
end

class If # args = {:condition, :consequence, :alternative}
  def to_ruby
    to_lambda_str %W(
      if (#{condition.to_ruby}).call(e) then
        (#{consequence.to_ruby}).call(e)
      else
        (#{alternative.to_ruby}).call(e)
      end
    )
  end
end

class Sequence
  def to_ruby
    to_lambda_str "(#{second.to_ruby}).call((#{first.to_ruby}).call(e))"
  end
end

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
