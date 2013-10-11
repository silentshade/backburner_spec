require 'backburner'

class Backburner::Worker
  class << self
    alias_method :enqueue_without_backburner_spec, :enqueue
  end

  def self.enqueue(*args)
    if BackburnerSpec.disable_ext
      enqueue_without_backburner_spec 
    else
      BackburnerSpec.enqueue(*args)
    end
  end
end