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

class NameFromClassMethod
  class << self
    attr_accessor :invocations

    def perform(*args)
      self.invocations += 1
    end

    def queue
      :name_from_class_method
    end
  end

  self.invocations = 0
end
