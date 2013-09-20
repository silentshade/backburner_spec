require "backburner_spec/version"
require "backburner_spec/ext"
require "backburner_spec/helpers"
require "backburner_spec/matchers"

module BackburnerSpec
  extend self

  attr_accessor :inline
  attr_accessor :disable_ext

  def queues
    @queues ||= Hash.new {|h,k| h[k] = []}
  end

  def reset!(class_name = nil)
    queues.clear
    self.inline = false
  end

  def enqueue(job_class, args=[], opts={})
    perform_or_store(job_class, args)
  end


  def perform_for_class(class_name)
    queue = queues[class_name.to_s]
    queue.each { |args|
      perform(class_name, args)
    }
  end

  def perform_first_for_class(class_name)
    queue = queues[class_name.to_s]
    perform(class_name, queue.first) 
  end

  def perform_all
    queues.keys.each {|k| perform_for_class(k) }
  end

  def immediately_perform
    stub_foo
    yield
    unstub_foo
  end


  private 

  def perform_or_store(class_name, args)
    if inline
      perform(class_name, args)
    else
      store(class_name, args)
    end
  end

  def store(class_name, args)
    queues[class_name.to_s] << args
  end

  def perform(class_name, args)
    Kernel.const_get(class_name.to_s).perform(*args)
  end
end

config = RSpec.configuration
config.include BackburnerSpec::Helpers