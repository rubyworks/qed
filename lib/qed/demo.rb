module QED

  require 'yaml'

  require 'qed/core_ext'
  require 'qed/parser'
  require 'qed/evaluator'

  # Ecapsulate a demonstration document.
  #
  class Demo

    #
    attr :applique

    # Demonstrandum file.
    attr :file

    #
    attr :mode

    #
    attr :scope

# TODO: Each demo should get it's own list of applique, starting with a private applique
# and working up the directory tree to the outer more test directory applique.

    # New Script
    def initialize(file, options={})
      @file     = file
      #@applique = applique
      @scope    = options[:scope] || Scope.new(applique, file)
      @mode     = options[:mode]
      @binding  = @scope.__binding__
      #@loadlist = []
      #apply_environment
    end

    # One binding per script.
    def binding
      @binding #||= @scope.__binding__
    end

    # TODO: demo advice vs. applique advice
    #def advice
    #  #@scope.__advice__
    #  @applique.__advice__
    #end

    #
    #def advise(signal, *args)
    #  advice.call(@scope, signal, *args)
    #end

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

    #
    def applique
      @applique ||= (
        [Applique.new] + applique_locations.map do |location|
          Applique.load(location)
        end
      )
    end

    #
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

    # Parse script.
    # Retruns an abstract syntax tree.
    def parse
      Parser.new(file, :mode=>mode).parse
    end

    #
    def run(*observers)
      evaluator = Evaluator.new(self, *observers)
      evaluator.run
    end

  end

end
