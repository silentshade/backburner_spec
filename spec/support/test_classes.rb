require 'backburner'

class Person
end

class Place
end

class Order

  include Backburner::Performable

  def method_without_args
  end

  def method_with_args(arg1, arg2)
  end
end

