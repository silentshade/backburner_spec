require 'backburner'

class Backburner::Worker
  class << self
    alias_method :enqueue_without_backburner_spec, :enqueue
  end

  def self.enqueue(job_class, args=[], opts={})
    if BackburnerSpec.disable_ext
      enqueue_without_backburner_spec 
    else
      BackburnerSpec.enqueue(job_class, args, opts)
    end
  end
end