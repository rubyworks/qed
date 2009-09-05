module QED

  # = Assertion
  #
  # This is the core class of the whole specification system.
  #
  class Assertion < Exception

    def initialize(message, backtrace=nil)
      super(message)
      set_backtrace(backtrace) if backtrace
    end

    def to_str
      message.to_s.strip
    end

  end

end

# Copyright (c) 2008 Tiger Ops

