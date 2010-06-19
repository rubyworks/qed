module QED
  require 'yaml'

  require 'facets/dir/ascend'

  require 'qed/parser'
  require 'qed/evaluator'

  # = Script
  #
  class Script

    #
    attr :applique

    # Demonstrandum file.
    attr :file

    #
    attr :scope

    # New Script
    def initialize(applique, file, scope=nil)
      @applique = applique.dup # localize copy of applique
      @file     = file
      @scope    = scope || Scope.new(applique)
      @binding  = @scope.__binding__
      #@loadlist = []
      #apply_environment
    end

    # One binding per script.
    def binding
      @binding #||= @scope.__binding__
    end

    #
    def advice
      #@scope.__advice__
      @applique.__advice__
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

    def parse
      Parser.new(file).parse
    end

    #
    def run(*observers)
      evaluator = Evaluator.new(self, *observers)
      evaluator.run
    end

  end

end

