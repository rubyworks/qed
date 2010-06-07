module QED

  require 'qed/advice/events'
  require 'qed/advice/patterns'

  # = Advice
  #
  # This class tracks advice defined by demo scripts
  # and helpers. It is instantiated in Scope, so that
  # the advice methods will have access to the same
  # local binding and the scripts themselves.
  #
  class Advice

    attr :patterns

    attr :events

    def initialize
      @patterns = Patterns.new
      @events   = Events.new
    end

    def call(scope, type, *args)
      case type
      when :when
        @patterns.call(scope, *args)
      else
        @events.call(scope, type, *args)
      end
    end
  end

end

