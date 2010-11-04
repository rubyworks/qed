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

    # Load cache.
    def self.cache
      @cache ||= {}
    end

    # TODO: may need to expand directory to be absolute path
    def self.load(directory)
      cache[directory] ||= (
        applique = new
        Dir[directory + '/**/*.rb'].each do |file|
          applique.module_eval(File.read(file), file)
        end
        applique
      )
    end

    #
    def initialize
      super()
      extend self

      @__matchers__ = []
      @__signals__  = {}
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
        type = patterns.first
        @__signals__[type] = procedure
      else
        @__matchers__ << [patterns, procedure]
      end
    end

    # Before advice.
    def Before(type=:code, &procedure)
      type = "before_#{type}".to_sym
      @__signals__[type] = procedure
    end

    # After advice.
    def After(type=:code, &procedure)
      type = "after_#{type}".to_sym
      @__signals__[type] = procedure
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

    # Redirect missing constants to Object class 
    # to simulate TOPLEVEL.
    #
    # TODO: Clean backtrace when constant is not found.
    def const_missing(name)
      Object.const_get(name)
    end

  end

end

