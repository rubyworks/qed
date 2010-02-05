module QED

  require 'qed/advice/events'
  require 'qed/advice/patterns'

  # = Advice
  #
  # This class tracks advice defined by demo scripts
  # and helpers. It is instantiated in Scope, so that
  # the advice methods will have access to the same
  # local binding and the demo scripts themselves.
  #
  class Advice

    attr :patterns

    attr :events

    def initialize
      @patterns = Patterns.new
      @events   = Events.new
    end

    def call(type, *args)
      case type
      when :when
        @patterns.call(*args)
      else
        @events.call(type, *args)
      end
    end
  end

  #
  module Advisable

    def __advice__
      @__advice__ ||= Advice.new
    end

    def When(pattern, &procedure)
      case pattern
      when Symbol
        __advice__.events.add(:"#{pattern}", &procedure)
      else
        __advice__.patterns.add(pattern, &procedure)
      end
    end

    def Before(type=:code, &procedure)
      __advice__.events.add(:"before_#{type}", &procedure)
    end

    def After(type=:code, &procedure)
      __advice__.events.add(:"after_#{type}", &procedure)
    end

  end

end

