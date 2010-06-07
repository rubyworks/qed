module QED

  # The Applique is the environment of libraries required by
  # and the rules to apply to demonstrandum. The applique is
  # defined by a set of scripts located in the +applique+ 
  # directory of the upper-most test directory relative to
  # the tests run and below the root of a project. All
  # applique scripts are loaded at the start of a test
  # session. Thus all demos belong to one and only one
  # applique, and all the scripts in an applique must be
  # compatible/consistant. For a tow demos to have separate
  # applique they must be kep in separate directores.

  class Applique < Module

    #
    def initialize
      super()
      extend self
      @__advice__ = Advice.new
    end

    #
    def initialize_copy(other)
      @__advice__ = other.__advice__.dup
    end

    # Redirect missing constants to Object class 
    # to simulate TOPLEVEL.
    def const_missing(name)
      Object.const_get(name)
    end

    #
    def __advice__
      @__advice__
    end

    # Because patterns are mathced against HTML documents
    # HTML special charaters +<+, +>+ and +&+ should not be
    # used.
    def When(*patterns, &procedure)
      if patterns.size == 1 && Symbol === patterns.first
        __advice__.events.add(:"#{patterns.first}", &procedure)
      else
        __advice__.patterns.add(patterns, &procedure)
      end
    end

    # Before advice.
    def Before(type=:code, &procedure)
      __advice__.events.add(:"before_#{type}", &procedure)
    end

    # After advice.
    def After(type=:code, &procedure)
      __advice__.events.add(:"after_#{type}", &procedure)
    end

    # Code match-and-transform procedure.
    #
    # This is useful to transform human readable code examples
    # into proper exectuable code. For example, say you want to
    # run shell code, but want to make if look like typical
    # shelle examples:
    #
    #    $ cp fixture/a.rb fixture/b.rb
    #
    # You can use a transform to convert lines starting with '$'
    # into executable Ruby using #system.
    #
    #    system('cp fixture/a.rb fixture/b.rb')
    #
    #def Transform(pattern=nil, &procedure)
    #
    #end

  end

end

