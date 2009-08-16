module QED

  module Grammar #:nodoc:

    module Legacy #:nodoc:

      # = Test::Unit Legacy Assertions
      #
      # This module provides a compatibility layer for Test::Unit.
      # This is an optional module and is intended for providing
      # an easier transition from Test::Unit::TestCase to Quarry
      # Specifications.
      #
      # Note that two methods are not provided, +#assert_nothing_raised+,
      # and +#assert_nothing_thrown+.
      #
      module Assertions

        # Private method upon which all of the legacy assertions are based
        # (except for #assert itself).
        #
        def __assert__(test, msg=nil)
          msg = "failed assertion (no message given)" unless msg
          raise Assertion.new(msg, caller[1..-1]) unless test
        end

        private :__assert__

        # The assertion upon which all other assertions are based.
        #
        #   assert [1, 2].include?(5)
        #
        def assert(test=nil, msg=nil)
          if test
            msg = "failed assertion (no message given)" unless msg
            raise Assertion.new(msg, caller) unless test
          else
            Expectation.new(self, :backtrace=>caller)
          end
        end

        # Passes if the block yields true.
        #
        # assert_block "Couldn't do the thing" do
        #   do_the_thing
        # end
        #
        def assert_block(msg=nil) # :yields:
          test = ! yield
          msg = "assertion failed" unless msg
          __assert__(test, msg)
        end

        # Passes if expected == +actual.
        #
        # Note that the ordering of arguments is important,
        # since a helpful error message is generated when this
        # one fails that tells you the values of expected and actual.
        #
        #   assert_equal 'MY STRING', 'my string'.upcase
        #
        def assert_equal(exp, act, msg=nil)
          test = (exp == act)
          msg  = "Expected #{act.inspect} to be equal to #{exp.inspect}" unless msg
          __assert__(test, msg)
        end

        # Passes if expected_float and actual_float are equal within delta tolerance.
        #
        #   assert_in_delta 0.05, (50000.0 / 10**6), 0.00001
        #
        def assert_in_delta(exp, act, delta, msg=nil)
          test = (exp.to_f - act.to_f).abs <= delta.to_f
          msg  = "Expected #{exp} to be within #{delta} of #{act}" unless msg
          __assert__(test, msg)
        end

        # Passes if object .instance_of? klass
        #
        #   assert_instance_of String, 'foo'
        #
        def assert_instance_of(cls, obj, msg=nil)
          test = (cls === obj)
          msg  = "Expected #{obj} to be a #{cls}" unless msg
          __assert__(test, msg)
        end

        # Passes if object .kind_of? klass
        #
        #   assert_kind_of Object, 'foo'
        #
        def assert_kind_of(cls, obj, msg=nil)
          test = obj.kind_of?(cls)
          msg  = "Expected #{obj.inspect} to be a kind of #{cls}" unless msg
          __assert__(test, msg)
        end

        # Passes if string =~ pattern.
        #
        #   assert_match(/\d+/, 'five, 6, seven')
        #
        def assert_match(exp, act, msg=nil)
          test = (act =~ exp)
          msg  = "Expected #{act.inspect} to match #{exp.inspect}" unless msg
          __assert__(test, msg)
        end

        # Passes if object is nil.
        #
        #   assert_nil [1, 2].uniq!
        #
        def assert_nil(obj, msg=nil)
          test = obj.nil?
          msg  = "Expected #{obj.inspect} to be nil" unless msg
          __assert__(test, msg)
        end

        # Passes if regexp !~ string
        #
        #   assert_no_match(/two/, 'one 2 three')
        #
        def assert_no_match(exp, act, msg=nil)
          test = (act !~ exp)
          msg  = "Expected #{act.inspect} to match #{exp.inspect}" unless msg
          __assert__(test, msg)
        end

        # Passes if expected != actual
        #
        #  assert_not_equal 'some string', 5
        #
        def assert_not_equal(exp, act, msg=nil)
          test = (exp != act)
          msg  = "Expected #{act.inspect} to not be equal to #{exp.inspect}" unless msg
          __assert__(test, msg)
        end

        # Passes if ! object .nil?
        #
        #   assert_not_nil '1 two 3'.sub!(/two/, '2')
        #
        def assert_not_nil(obj, msg=nil)
          test = ! obj.nil?
          msg  = "Expected #{obj.inspect} to not be nil" unless msg
          __assert__(test, msg)
        end

        # Passes if ! actual .equal? expected
        #
        #   assert_not_same Object.new, Object.new
        #
        def assert_not_same(exp, act, msg=nil)
          test = ! exp.equal?(act)
          msg  = "Expected #{act.inspect} to not be the same as #{exp.inspect}" unless msg
          __assert__(test, msg)
        end

        # Compares the +object1+ with +object2+ using operator.
        #
        # Passes if object1.send(operator, object2) is true.
        #
        #   assert_operator 5, :>=, 4
        #
        def assert_operator(o1, op, o2, msg="")
          test = o1.__send__(op, o2)
          msg = "Expected #{o1}.#{op}(#{o2}) to be true" unless msg
          __assert__(test, msg)
        end

        # Passes if the block raises one of the given exceptions.
        #
        #   assert_raise RuntimeError, LoadError do
        #     raise 'Boom!!!'
        #   end
        #
        def assert_raises(*args)
          if msg = (Module === args.last ? nil : args.pop)
          begin
            yield
            msg = "Expected #{exp} to be raised" unless msg
            __assert__(false, msg)
          rescue Exception => e
            test = (exp === e)
            msg  = "Expected #{exp} to be raised, but got #{e.class}" unless msg
            __assert__(test, msg)
            return e
          end
        end

        alias_method :assert_raise, :assert_raises

        # Provides a way to assert that a procedure
        # <i>does not</i> raise an exception.
        #
        #   refute_raises(StandardError){ raise }
        #
        #def assert_raises!(exception, &block)
        #  begin
        #    block.call(*a)
        #  rescue exception
        #    raise Assertion
        #  end
        #end
        #alias_method :refute_raises, :assert_raises!

        # Passes if +object+ respond_to? +method+.
        #
        #   assert_respond_to 'bugbear', :slice
        #
        def assert_respond_to(obj, meth, msg=nil)
          msg  = "Expected #{obj} (#{obj.class}) to respond to ##{meth}" unless msg
          #flip = (Symbol === obj) && ! (Symbol === meth) # HACK for specs
          #obj, meth = meth, obj if flip
          test = obj.respond_to?(meth)
          __assert__(test, msg)
        end

        # Passes if +actual+ .equal? +expected+ (i.e. they are the same instance).
        #
        #   o = Object.new
        #   assert_same(o, o)
        #
        def assert_same(exp, act, msg=nil)
          msg  = "Expected #{act.inspect} to be the same as #{exp.inspect}" unless msg
          test = exp.equal?(act)
          __assert__(test, msg)
        end

        # Passes if the method send returns a true value.
        # The parameter +send_array+ is composed of:
        #
        # * A receiver
        # * A method
        # * Arguments to the method
        #
        # Example:
        #
        #   assert_send [[1, 2], :include?, 4]
        #
        def assert_send(send_array, msg=nil)
          r, m, *args = *send_array
          test = r.__send__(m, *args)
          msg  = "Expected #{r}.#{m}(*#{args.inspect}) to return true" unless msg
          __assert__(test, msg)
        end

        # Passes if the block throws expected_symbol
        #
        #   assert_throws :done do
        #     throw :done
        #   end
        #
        def assert_throws(sym, msg=nil)
          msg  = "Expected #{sym} to have been thrown" unless msg
          test = true
          catch(sym) do
            begin
              yield
            rescue ArgumentError => e     # 1.9 exception
              default += ", not #{e.message.split(/ /).last}"
            rescue NameError => e         # 1.8 exception
              default += ", not #{e.name.inspect}"
            end
            test = false
          end
          __assert__(test, msg)
        end

        # Flunk always fails.
        #
        #   flunk 'Not done testing yet.'
        #
        def flunk(msg=nil)
          __assert__(false, msg)
        end

      end #module Assertions

    end #module Legacy

  end #module Grammar

  # This could be in Object, but since they will only be needed in
  # the context of a, well, Context...
  #
  class Context #:nodoc:
    include Grammar::Legacy::Assertions
  end

end #module Quarry

