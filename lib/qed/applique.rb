module QED

  # The Applique is the environment of libraries required by and the rules
  # to apply to demonstrandum. The applique is defined by a set of scripts
  # located in the +applique+ directory of the upper-most test directory
  # relative to the tests run and below the root of a project. All applique
  # scripts are loaded at the start of a test session. Thus all demos belong
  # to one and only one applique, and all the scripts in an applique must be
  # compatible/consistant. For two demos to have separate applique they must
  # be kept in separate directores.
  #
  class Applique < Module

    #
    def initialize
      super()
      extend self

      #@__advice__ = Advice.new

      @__matchers__ = []
      @__signals__  = [{}]
    end

    #
    def initialize_copy(other)
      #@__advice__ = other.__advice__.dup
      #@__matchers__ = []
      #@__signals__  = [{}]
    end

    #
    attr :__matchers__

    #
    attr :__signals__

    #
    #def __advice__
    #  @__advice__
    #end

    # Pattern matchers and "upon" events.
    def When(*patterns, &procedure)
      if patterns.size == 1 && Symbol === patterns.first
        type = patterns.first
        @__signals__.last[type] = procedure
        #__advice__.add_event(patterns.first, &procedure)
      else
        #__advice__.add_match(patterns, &procedure)
        @__matchers__ << [patterns, procedure]
      end
    end

    # Before advice.
    def Before(type=:code, &procedure)
      #__advice__.add_event(:"before_#{type}", &procedure)
      type = "before_#{type}".to_sym
      @__signals__.last[type] = procedure
    end

    # After advice.
    def After(type=:code, &procedure)
      #__advice__.add_event(:"after_#{type}", &procedure)
      type = "after_#{type}".to_sym
      @__signals__.last[type] = procedure
    end

    #
    #def add_event(type, &procedure)
    #  @signals.last[type.to_sym] = procedure
    #end

    #
    #def add_match(patterns, &procedure)
    #  @matchers << [patterns, procedure]
    #end

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

    # Redirect missing constants to Object class 
    # to simulate TOPLEVEL.
    #
    # TODO: Clean backtrace when constant is not found.
    def const_missing(name)
      Object.const_get(name)
    end

  end

end

