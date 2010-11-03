module QED

  require 'qed/expectation'

  module Grammar

    # = Should Nomenclature
    #
    # The term *should* has become the defacto standard for
    # BDD assertions, so Quarry supports this nomenclature.
    #
    module Should

      # Same as #expect but only as a functor.
      #
      #   4.should == 3  #=> Expectation Error
      #
      def should
        return Expectation.new(self, :backtrace=>caller)
      end

      # Designate a negated expectation via a *functor*.
      # Read this as "should not".
      #
      #   4.should! == 4  #=> Expectation Error
      #
      # See also #expect!
      #
      def should!
        return Expectation.new(self, :negate=>true, :backtrace=>caller)
      end

      # See #should! method.
      #
      alias_method :should_not, :should!

      #
      #alias_method :should_raise, :assert_raises

      #
      #alias_method :should_not_raise, :assert_raises!

    end

  end

  class ::Object #:nodoc:
    include Grammar::Should
  end

end

