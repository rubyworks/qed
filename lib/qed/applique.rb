module QED

  # Applique is a module built per-script from the +applique+ directory.
  # Applique scripts are loaded at the start of a session.
  #
  # *The Applique* is the whole collection of appliques that apply to given
  # demonstrandum. The applique that apply are the scripts located in the
  # directory relative to the demonstrandum script and all such directories
  # above this upto and the project's root directory.
  #
  # All scripts in the Applique must be compatible/consistant. For two demos to
  # have separate applique they must be kept in separate directories.
  #
  class Applique < Module

    # Load cache.
    def self.cache
      @cache ||= {}
    end

    # TODO: may need to expand file to be absolute path

    # Create new Applique caching instance based-on +file+.
    #
    # @param [String] file
    #   The file path to the applique file.
    #
    def self.for(file)
      cache[file] ||= new(file)
    end

    # Setup new Applique instance.
    #
    # @param [String] file
    #   The file path to the applique file.
    #
    def initialize(file=nil)
      super()
      extend self

      @__matchers__ = []
      @__signals__  = {}

      if file
        @file = file
        case File.extname(file)
        when '.rb'
          module_eval(File.read(file), file)
        else
          # little bit of a trick here, we create a new demo but manually
          # set the applique. That way the applique files won't be reloaded.
          # we then run the demo that applique get loaded.
          demo = Demo.new(file, :applique=>[self])
          Evaluator.run(demo, :applique=>true)
        end
      end
    end

    # Duplicate matcher and signal advice when duplicting applique.
    #
    # @param [Applique] other
    #   The original applique.
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
    #
    # @param [Symbol,Array<String,Regexp>] patterns
    #   Event signal, or list of matches.
    #
    # @yield Procedure to run on event.
    def When(*patterns, &procedure)
      if patterns.size == 1 && Symbol === patterns.first
        type = "#{patterns.first}".to_sym
        @__signals__[type] = procedure
        #define_method(type, &procedure)
      else
        patterns = patterns.map do |p|
          if String === p
            p.split('...').map{ |e| e.strip } 
          else
            p
          end
        end.flatten
        @__matchers__ << [patterns, procedure]
      end
    end

    # Before advice.
    #
    # @param [Symbol] type
    #   Event signal (`:eval`).
    #
    # @yield Procedure to run on event.
    def Before(type=:eval, &procedure)
      type = "before_#{type}".to_sym
      @__signals__[type] = procedure
      #define_method(type, &procedure)
    end

    # After advice.
    #
    # @param [Symbol] type
    #   Event signal (`:eval`).
    #
    # @yield Procedure to run on event.
    def After(type=:eval, &procedure)
      type = "after_#{type}".to_sym
      @__signals__[type] = procedure
      #define_method(type, &procedure)
    end

    # Code match-and-transform procedure.
    #
    # This is useful to transform human readable code examples
    # into proper exectuable code. For example, say you want to
    # run shell code, but want to make if look like typical
    # shell examples:
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

    # TODO: Clean backtrace when constant is not found ?

    # Redirect missing constants to Object classto simulate TOPLEVEL.
    #
    def const_missing(name)
      Object.const_get(name)
    end

  end

end
