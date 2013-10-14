require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'


module InQueueHelper
  include Backburner::Helpers
  def self.extended(klass)
    klass.instance_eval do
      chain :in do |tube|
        @tube = tube
      end
    end
  end

  def fetch_que(klass, tube = nil)
    full_tube_name = expand_tube_name(tube || klass) 
    BackburnerSpec.queues[full_tube_name]
  end

  def fetch_for_class(klass, tube = nil)
    fetch_que(klass, tube).select do |entry|
      entry[:class] == klass.name
    end
  end

  def check_matched_size(matched, times)
    if times
      matched.size == times
    else
      matched.size > 0
    end
  end

end


module QueueCountHelper
  include Backburner::Helpers
  def self.extended(klass)
    klass.instance_eval do
      chain :times do |num_times_queued|
        @times = num_times_queued
        @times_info = @times == 1 ? ' once' : " #{@times} times"
      end

      chain :once do |num_times_queued|
        @times = 1
        @times_info = ' once'
      end
    end
  end
end




RSpec::Matchers.define :have_performed do |method_name|
  extend InQueueHelper
  extend QueueCountHelper

  chain :with do |*args|
    @args = args
    @args_info = " with #{@args}"
  end

  match do |actual|
    if actual.is_a? Class
      actual_class = actual
      actual_id = nil
    else
      actual_class = actual.class
      actual_id = actual.id
    end

    matched = fetch_for_class(actual_class, @tube).select do |entry|
      if @args 
        entry[:args] == [actual_id, method_name] + @args
      else
        entry[:args].slice(0..1) == [actual_id, method_name]
      end
    end

    check_matched_size(matched, @times)
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

RSpec::Matchers.define :have_enqueued do |*expected_args|
  extend InQueueHelper
  extend QueueCountHelper

  match do |actual_class|
    matched = fetch_for_class(actual_class, @tube).select do |entry|
      entry[:args] == expected_args
    end
    check_matched_size(matched, @times)
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would enqueue :#{@actual_class.to_s} with #{expected_args}#{@times_info}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not enqueue :#{@actual_class.to_s} with #{expected_args}#{@times_info}"
  end

  description do
    "have enqueued :#{@actual_class.to_s} with #{expected_args} #{@times_info}"
  end
end

RSpec::Matchers.define :have_queue_size_of do |size|
  extend InQueueHelper

  match do |actual|
    (@actual_size = fetch_que(actual, @tube).size) == size
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would have #{size} entries queued, but got #{@actual_size} instead"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not have #{size} entries queued, but got #{@actual_size} instead"
  end

  description do
    "have a queue size of #{size}"
  end
end

RSpec::Matchers.define :have_queue_size_of_at_least do |size|
  extend InQueueHelper

  match do |actual|
    (@actual_size = fetch_que(actual, @tube).size) >= size
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would have at least #{size} entries queued, but got #{@actual_size} instead"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not have at least #{size} entries queued, but got #{@actual_size} instead"
  end

  description do
    "have a queue size of at least #{size}"
  end
end