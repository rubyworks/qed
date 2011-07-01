require 'ae'

module QED

  # Scope is the context in which QED documents are run.
  #
  class Scope < Module

    # Location of `qed/scope.rb`.
    DIRECTORY = File.dirname(__FILE__)

    #
    #    def self.new(applique, file)
    #      @_applique = applique
    #      super(applique, file)
    #    end

    #    #
    #    def self.const_missing(name)
    #      @_applique.const_get(name)
    #    end

    #
    def initialize(applique, cwd, file=nil)
      super()
      @_applique = applique
      @_cwd      = cwd
      @_file     = file
      #@loadlist = []

      include *applique
      #extend self
      #extend applique # TODO: extend or include applique or none ?
      #extend DSLi

      # TODO: custom extends?

      __create_clean_binding_method__
    end

    # This turns out to be the key to proper scoping.
    def __create_clean_binding_method__
      #define_method(:__binding__) do
      #  @__binding__ ||= binding
      #end
      module_eval %{
        def __binding__
          @__binding__ ||= binding
        end
      }
    end

    #
    def include(*modules)
      super(*modules)
      extend self
    end

    # Expanded dirname of +file+.
    def demo_directory
      @_demo_directory ||= File.expand_path(File.dirname(@_file))
    end

    # Evaluate code in the context of the scope's special binding.
    # The return result of the evaluation is stored in `@_`.
    def eval(code, file=nil, line=nil)
      @_ = super(code, __binding__, @_file, line)
    end


    # Utilize is like #require, but will evaluate the script in the context
    # of the current scope.
    #--
    # TODO: Alternative to Plugin gem?
    #
    # TODO: Should work like require so same file isn't loaded twice.
    #++
    def utilize(file)
      file = Dir[DIRECTORY + "/helpers/#{file}"].first
      if !file
        require 'plugin'
        file = Plugin.find("#{file}{,.rb}", :directory=>nil)
      end
      if file
        code = File.read(file)
        eval(code, nil, file)
      else
        raise LoadError, "no such file -- #{file}"
      end
    end


    # Define "when" advice.
    def When(*patterns, &procedure)
      patterns = patterns.map{ |pat| pat == :text ? :desc : pat }
      @_applique.first.When(*patterns, &procedure)
    end

    # Define "before" advice. Default type is :each, which
    # evaluates just before example code is run.
    def Before(type=:each, &procedure)
      type = :step if type == :each
      type = :demo if type == :all
      @_applique.first.Before(type, &procedure)
    end

    # Define "after" advice. Default type is :each, which
    # evaluates just after example code is run.
    def After(type=:each, &procedure)
      type = :step if type == :each
      type = :demo if type == :all
      @_applique.first.After(type, &procedure)
    end

    # Directory of current document.
    def __DIR__(file=nil)
      if file
        Dir.glob(File.join(File.dirname(@_file), file)).first || file
      else
        File.dirname(@_file)
      end
    end

    # TODO: Should Table and Data be extensions that can be loaded if desired?

    # Use sample table to run steps. The table file is located relative to
    # the demo, failing that it will be looked for relative to the working
    # directory.
    #
    # TODO: Cache data for speed ?
    def Table(file=nil, options={}) #:yield:
      if file
        file = Dir.glob(File.join(File.dirname(@_file), file)).first || file
      else
        file = @_last_table
      end
      @_last_table = file

      file_handle = File.new(file)

      if options[:stream]
        if block_given?
          YAML.load_documents(file_handle) do |data|
            yield data
          end
        else
          YAML.load_stream(file_handle)
        end
      else
        if block_given?
          tbl = YAML.load(file_handle)
          tbl.each do |data|
            yield(*data)
          end
        else
          YAML.load(file_handle)
        end
      end
    end

    # Read a static data file and yield contents to block if given.
    #
    # This method no longer automatically uses YAML.load.
    #--
    # TODO: Cache data for speed ?
    #++
    def Data(file) #:yield:
      file = Dir.glob(File.join(File.dirname(@_file), file)).first || file
      #case File.extname(file)
      #when '.yml', '.yaml'
      #  data = YAML.load(File.new(file))
      #else
        data = File.read(file)
      #end
      if block_given?
        yield(data)
      else
        data
      end
    end

    # Clear temporary work directory.
    def clear_working_directory!
      dir = @_cwd
      dir = File.expand_path(dir)

      if dir == '/' or dir == File.expand_path('~')
        abort "DANGER! Trying to use home or root as a temporary directory!"
      end

      entries = Dir.glob(File.join(dir, '**/*'))

      dirs, files = entries.partition{ |f| File.directory?(f) }

      files.each { |file| FileUtils.rm(file)   }
      dirs.each  { |dir|  FileUtils.rmdir(dir) }
    end

    #
    def const_missing(const)
      Object.const_get(const)
    end

  end#class Scope

end#module QED
