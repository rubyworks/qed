module Respect

  require 'respect/expectation'

  module Grammar

    # = Assert Nomenclature
    #
    module Assert

      # Assert a operational relationship.
      #
      #   4.assert == 3
      #
      # If only a single test argument is given then
      # #assert simple validates that it evalutate to true.
      # An optional message argument can be given in this
      # case which will be used instead of the deafult message.
      #
      #   assert(4==3, "not the same thing")
      #
      # In block form, #assert ensures the block evalutes
      # truthfully, i.e. not as nil or false.
      #
      #   assert{ 4==3 }
      #
      # If an argument is given with a block, #assert compares
      # the argument to the result of evaluating the block.
      #
      #   assert(4){ 3 }
      #
      # #assert compares the expected value and the actual
      # value with regular equality <code>#==</code>.
      #
      def assert(test=Exception, msg=nil, &block)
        if block
          act = block.call
          if test == Exception
            raise Assertion.new(msg, caller) unless act
          else
            yes = (test == act)
            msg = "#{exp}.equate? #{act}" unless msg
            raise Assertion.new(msg, caller) unless yes
          end
        elsif test != Exception
          msg = "failed assertion (no message given)" unless msg
          raise Assertion.new(msg, caller) unless test
        else
          return Expectation.new(self, :backtrace=>caller)
        end
      end

      # Assert not an operational relationship.
      # Read it as "assert not".
      #
      #   4.assert! == 4
      #
      # See #assert.
      #
      # AUHTOR'S NOTE: This method would not be necessary
      # if Ruby would allow +!=+ to be define as a method,
      # or at least +!+ as a unary method.
      #
      def assert!(test=Exception, msg=nil, &block)
        if block
          act = block.call
          if test == Exception
            raise Assertion.new(msg, caller) if act
          else
            yes = (test == act)
            msg = "#{exp}.equate? #{act}" unless msg
            raise Assertion.new(msg, caller) if yes
          end
        elsif test != Exception
          msg = "failed assertion (no message given)" unless msg
          raise Assertion.new(msg, caller) if test
        else
          return Expectation.new(self, :negate=>true, :backtrace=>caller)
        end

        if test
          msg = "failed assertion (no message given)" unless msg
          raise Assertion.new(msg, caller) if test
        else
          return Expectation.new(self, :negate=>true, :backtrace=>caller)
        end
      end

      # Same as #assert!.
      #
      # 4.refute == 4  #=> Assertion Error
      #
      alias_method :refute, :assert!

    end

  end

  class ::Object #:nodoc:
    include Grammar::Assert
  end

end

