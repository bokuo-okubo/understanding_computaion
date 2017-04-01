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
