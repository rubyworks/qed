module QED

  require 'qed/expectation'

  module Grammar

    # = Expect Nomenclature
    #
    # Provides expect nomenclature. This is Quarry's "standard"
    # nomenclature.
    #
    module Expect

      # The +expect+ method is a powerful tool for defining
      # expectations in your specifications.
      #
      # Like #should it can be used to Designate an expectation
      # via a *functor*.
      #
      #   4.expect == 3
      #
      # Or it can be used in block form.
      #
      #   expect(4){ 3 }
      #
      # This compares the expected value and the actual
      # value with <i>broad equality</i>. This is similar to
      # case equality (#===) but also checks other forms of
      # equality. See the #equate method.
      #
      # Of particluar utility is that #expect allows one to
      # specify if the block raises the error.
      #
      #   expect NoMethodError do
      #     not_a_method
      #   end
      #
      def expect(exp=Expectation, &block)
        if exp == Expectation
          Expectation.new(self, :backtrace=>caller)
        elsif Exception >= exp
          begin
            act  = block.call
            test = exp.equate?(act)
            msg  = "#{exp}.equate? #{act}"
          rescue exp => error
            test = true
            #msg  = "#{exp} expected to be raised"
          rescue Exception => error
            test = false
            msg  = "#{exp} expected but #{error.class} was raised"
          end
          raise Assertion.new(msg, caller) unless test
        else
          act  = block.call
          test = exp.equate?(act)
          msg  = "#{exp}.equate? #{act}"
          raise Assertion.new(msg, caller) unless test
        end
      end

      # Designate a negated expectation. Read this as
      # "expect not".
      #
      #   4.expect! == 4  #=> Expectation Error
      #
      # See #expect.
      #
      # Note that this method would not be necessary if
      # Ruby would allow +!=+ to be defined as a method,
      # or perhaps +!+ as a unary method.
      #
      def expect!(exp=Expectation, &block)
        if exp == Expectation
          Expectation.new(self, :negate=>true, :backtrace=>caller)
        elsif Exception >= exp
          begin
            act  = block.call
            test = !exp.equate?(act)
            msg  = "! #{exp}.equate? #{act}"
          rescue exp => error
            test = false
            msg  = "#{exp} raised"
          rescue Exception => error
            test = true
            #msg  = "#{exp} expected but was #{error.class}"
          end
          raise Assertion.new(msg, caller) unless test
        else
          act  = block.call
          test = !exp.equate?(act)
          msg  = "! #{exp}.equate? #{act}"
          raise Assertion.new(msg, caller) unless test
        end
      end

      # See #expect! method.
      #
      alias_method :expect_not, :expect!

    end

  end

  class ::Object #:nodoc:
    include Grammar::Expect
  end

  module ::Kernel
    # Broad equality.
    #
    def equate?(actual)
      self.equal?(actual) ||
      self.eql?(actual)   ||
      self == actual      ||
      self === actual
    end
  end

end

