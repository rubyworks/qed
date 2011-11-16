module QED

  # Applique is a module built per-script from the +applique+ dirctory.
  # Applique scripts are loaded at the start of a session.
  #
  # <i>The Applique</i> is whole collection of applique that apply to given
  # demonstrandum. The applique that apply are the scripts located in the
  # directory relative to the demonstrandum script and all such directories
  # above this upto and the project's root directory.
  #
  # All scripts in the Applique must be compatible/consistant. For two demos to
  # have separate applique must be kept in separate directores.
  #
  class Applique < Module

    # Load cache.
    def self.cache
      @cache ||= {}
    end

    class << self
      alias_method :_new, :new
    end

    # New method caches Applique based-on +file+, if given.
    #--
    # TODO: may need to expand file to be absolute path
    #++
    def self.new(file=nil)
      if file
        cache[file] ||= _new(file)
      else
        _new(file)
      end
    end

    #
    def initialize(file=nil)
      super()
      extend self

      @__matchers__ = []
      @__signals__  = {}

      if file
        @file = file
        module_eval(File.read(file), file)
      end
    end

    #
    def initialize_copy(other)
      @__matchers__ = other.__matchers__.dup
      @__signals__  = other.__signals__.dup
    end

    # Array of matchers.
    attr :__matchers__

    # Hash of signals.
    attr :__signals__

    # Pattern matchers and "upon" events.
    def When(*patterns, &procedure)
      if patterns.size == 1 && Symbol === patterns.first
        type = "#{patterns.first}".to_sym
        @__signals__[type] = procedure
        #define_method(type, &procedure)
      else
        @__matchers__ << [patterns, procedure]
      end
    end
    alias_method :Rule, :When

    # Before advice.
    def Before(type=:code, &procedure)
      type = "before_#{type}".to_sym
      @__signals__[type] = procedure
      #define_method(type, &procedure)
    end

    # After advice.
    def After(type=:code, &procedure)
      type = "after_#{type}".to_sym
      @__signals__[type] = procedure
      #define_method(type, &procedure)
    end

    # TODO: Is it wise to support lower-case?
    alias_method :rule,   :When
    alias_method :before, :Before
    alias_method :after,  :After

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

