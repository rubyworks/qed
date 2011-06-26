module QED

  require 'yaml'

  require 'qed/core_ext'
  require 'qed/parser'
  require 'qed/evaluator'
  require 'qed/applique'

  # The Demo class ecapsulates a demonstration document.
  #
  class Demo

    # Demonstrandum file.
    attr :file

    # Parser mode.
    attr :mode

    # Working directory.
    attr :cwd

    # Scope to run demonstration within. (Known as a "World" in Cucumber.)
    attr :scope

    # New Script
    def initialize(file, options={})
      @file    = file
      @mode    = options[:mode]
      @cwd     = options[:at] || fallback_cwd

      @scope   = options[:scope] || Scope.new(applique, cwd, file)

      @binding = @scope.__binding__
      #apply_environment
    end

    # One binding per demo.
    def binding
      @binding #||= @scope.__binding__
    end

    # Expanded dirname of +file+.
    def directory
      @directory ||= File.expand_path(File.dirname(file))
    end

    # File basename less extension.
    def name
      @name ||= File.basename(file).chomp(File.extname(file))
    end

    #
    def evaluate(code, line)
      #eval(code, @binding, @file, line)
      @scope.eval(code, @file, line)
    end

    # Returns a cached Array of Applique modules.
    def applique
      @applique ||= (
        list = [Applique.new]
        applique_locations.each do |location|
          Dir[location + '/**/*.rb'].each do |file|
            list << Applique.new(file)
          end
        end
        list
      )
    end

    # Returns a list of applique directories to be used by this
    # demonstrastion.
    def applique_locations
      @applique_locations ||= (
        locations = []
        Dir.ascend(File.dirname(file)) do |path|
          break if path == Dir.pwd
          dir = File.join(path, 'applique')
          if File.directory?(dir)
            locations << dir
          end
        end
        locations
      )
    end

    # Demo steps, cached from parsing.
    #
    # @return [Array] parsed steps
    def steps
      @steps ||= parser.parse
    end

    # Parse and cache demonstration script.
    #
    # @return [Array] abstract syntax tree
    alias_method :parse, :steps

    # Get a new Parser instance for this demo.
    #
    # @return [Parser] parser for this demo
    def parser
      Parser.new(file, :mode=>mode)
    end

    #
    def run(*observers)
      evaluator = Evaluator.new(self, *observers)
      evaluator.run
    end

    #
    #def source
    #  @source ||= (
    #    #case file
    #    #when /^http/
    #    #  ext  = File.extname(file).sub('.','')
    #    #  open(file)
    #    #else
    #      File.read(file)
    #    #end
    #  )
    #end

    # This shouldn't be needed, but is here as a precaution.
    def fallback_cwd
      @dir ||= File.join(Dir.tmpdir, 'qed', File.filename(Dir.pwd), Time.new.strftime("%Y%m%d%H%M%S"))
    end

  end

end
