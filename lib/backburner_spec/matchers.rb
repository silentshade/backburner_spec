require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'

RSpec::Matchers.define :have_performed do |method_name|

  chain :with do |*args|
    @args = args
    @args_info = " with #{@args}"
  end

  chain :times do |num_times_queued|
    @times = num_times_queued
    @times_info = @times == 1 ? ' once' : " #{@times} times"
  end

  chain :once do |num_times_queued|
    @times = 1
    @times_info = ' once'
  end

  match do |actual|
    if actual.is_a? Class
      class_name = actual.self.to_s
      actual_id = nil
    else
      class_name = actual.class.to_s
      actual_id = actual.id
    end
    
    matched = BackburnerSpec.queues[class_name].select do |entry|
      basic = (entry[0] == actual_id && entry[1] == method_name)
      if @args
        basic && entry.slice(2..-1) == @args
      else
        basic
      end
    end

    if @times
      matched.size == @times
    else
      matched.size > 0
    end
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would perform :#{method_name}#{@args_info}#{@times_info}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not perform :#{method_name}#{@args_info}#{@times_info}"
  end

  description do
    "have performed :#{method_name}#{@args_info}#{@times_info}"
  end
end
