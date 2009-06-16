module Respect

  require 'respect/assertion'

  # = Expectation
  #
  # Expectation is an Assertion Functor.
  #
  class Expectation

    hide = instance_methods.select{ |m| m.to_s !~ /^__/ }
    hide.each{ |m| protected m  }

    private

    # New Expectation.
    #
    def initialize(delegate, ioc={}) #, backtrace)
      @delegate  = delegate
      @negate    = ioc[:negate]
      @message   = ioc[:message]
      @backtrace = ioc[:backtrace] || caller #[1..-1]
    end

    # Converts missing method into an Assertion.
    #
    def method_missing(sym, *a, &b)
      test = @delegate.__send__(sym, *a, &b)

      if (@negate ? test : !test)
        msg   = @message || __msg__(sym, *a, &b)
        error = Assertion.new(msg)
        error.set_backtrace(@backtrace)
        raise error
      end
    end

    # Puts together a suitable error message.
    #
    def __msg__(m, *a, &b)
      if @negate
        "! #{@delegate.inspect} #{m} #{a.collect{|x| x.inspect}.join(',')}"
      else
        "#{@delegate.inspect} #{m} #{a.collect{|x| x.inspect}.join(',')}"
      end
      #self.class.message(m)[@delegate, *a] )
    end

    # TODO: Ultimately better messages would be nice ?
    #
    #def self.message(op,&block)
    #  @message ||= {}
    #  block ? @message[op.to_sym] = block : @message[op.to_sym]
    #end
    #
    #message(:==){ |*a| "Expected #{a[0].inspect} to be equal to #{a[1].inspect}" }
  end

end

