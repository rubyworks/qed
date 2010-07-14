require 'ae'

module QED

  # Scope is the context in which QED documents are run.
  #
  class Scope < Module
 
    #
    def self.new(applique, file)
      @_applique = applique
      super(applique, file)
    end

    #
    def self.const_missing(name)
      @_applique.const_get(name)
    end

    #
    def initialize(applique, file=nil)
      super()
      @_applique = applique
      @_file     = file

      extend self
      extend applique # TODO: extend or include applique or none ?
      #extend DSLi

      # TODO: custom extends?

      __create_clean_binding_method__
    end

    # This turns out to be the key to proper scoping.
    def __create_clean_binding_method__
      define_method(:__binding__) do
        @__binding__ ||= binding
      end
    end

    # Evaluate code in the context of the scope's special 
    # binding.
    def eval(code, binding=nil)
      super(code, binding || __binding__)
    end

    # Define "when" advice.
    def When(*patterns, &procedure)
      @_applique.When(*patterns, &procedure)
    end

    # Define "before" advice. Default type is :each, which
    # evaluates just before example code is run.
    def Before(type=:each, &procedure)
      type = :step if type == :each
      type = :demo if type == :all
      @_applique.Before(type, &procedure)
    end

    # Define "after" advice. Default type is :each, which
    # evaluates just after example code is run.
    def After(type=:each, &procedure)
      type = :step if type == :each
      type = :demo if type == :all
      @_applique.After(type, &procedure)
    end

    # TODO: Should Table and Data be extensions that can be loaded if desired?

    # Use sample table to run steps. The table file will be
    # looked for relative to the demo, failing that it will
    # be looked for relative to the working directory.
    #
    # TODO: Cache data for speed ?
    def Table(file=nil) #:yield:
      if file
        file = Dir.glob(File.join(File.dirname(@_file), file)).first || file
      else
        file = @_last_table
      end
      @_last_table = file

      tbl  = YAML.load(File.new(file))
      tbl.each do |set|
        yield(*set)
      end
    end

    # Read a static data sample.
    #
    # TODO: Cache data for speed ?
    def Data(file) #:yield:
      #raise if File.directory?(file)
      #if content
      #  FileUtils.mkdir_p(File.dirname(file))
      #  case File.extname(file)
      #  when '.yml', '.yaml'
      #    File.open(file, 'w'){ |f| f << content.call.to_yaml }
      #  else
      #    File.open(file, 'w'){ |f| f << content.call }
      #  end
      #else
        #raise LoadError, "no such fixture file -- #{fname}" unless File.exist?(fname)
        file = Dir.glob(File.join(File.dirname(@_file), file)).first || file
        case File.extname(file)
        when '.yml', '.yaml'
          data = YAML.load(File.new(file))
        else
          data = File.read(file)
        end
        if block_given?
          yield(data)
        else
          data
        end
      #end
    end

  end#class Scope

end#module QED

