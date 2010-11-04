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

    # Scope to run demonstration within. (Known as a "World" in Cucumber.)
    attr :scope

    # New Script
    def initialize(file, options={})
      @file     = file
      @scope    = options[:scope] || Scope.new(applique, file)
      @mode     = options[:mode]
      @binding  = @scope.__binding__
      #apply_environment
    end

    # One binding per script.
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
      eval(code, @binding, @file, line)
      #@scope.module_eval(section.text, @file, section.line)
    end

    # Returns a cached Array of Applique modules.
    def applique
      @applique ||= (
        [Applique.new] + applique_locations.map do |location|
          Applique.load(location)
        end
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

    # Parse demonstration script.
    #
    # Returns an abstract syntax tree.
    def parse
      Parser.new(file, :mode=>mode).parse
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

  end

end
