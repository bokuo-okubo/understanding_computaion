require '../../base_definitions.rb'

def to_lambda_str(_inspect)
  "-> e { #{_inspect} }"
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
