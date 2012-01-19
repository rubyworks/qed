module QED

  require 'yaml'

  require 'qed/core_ext'
  require 'qed/parser'
  require 'qed/evaluator'
  require 'qed/applique'

  # The Demo class ecapsulates a demonstrandum script.
  #
  class Demo

    # Demonstrandum file.
    attr :file

    # Parser mode.
    attr :mode

    # Steup new Demo instance.
    #
    # @param [String] file
    #   Path to demo file.
    #
    # @param [Hash] options
    #
    # @option options [Symbol] :mode
    #   Either `:comment` or other for normal mode.
    #
    # @option options [Strng] :at
    #   Working directory.
    #
    # @option options [Array] :applique
    #   Overriding applique. Used to import demos into other demos safely.
    #
    # @option options [Scope] :scope
    #   Overriding scope, otherwise new Scope instance is created.
    #
    def initialize(file, options={})
      @file     = file

      @mode     = options[:mode]
      @applique = options[:applique]
    end

    # Expanded dirname of +file+.
    def directory
      @directory ||= File.expand_path(File.dirname(file))
    end

    # File basename less extension.
    def name
      @name ||= File.basename(file).chomp(File.extname(file))
    end

    # Returns a cached Array of Applique modules.
    def applique
      @applique ||= (
        list = [Applique.new]
        applique_locations.each do |location|
          #Dir[location + '/**/*'].each do |file|
          Dir[location + '/*'].each do |file|
            next if File.directory?(file)
            list << Applique.for(file)
          end
        end
        list
      )
    end

    #
    def applique_prime
      applique.first
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
    # @return [Array] list of steps (abstract syntax tree)
    alias_method :parse, :steps

    # Get a new Parser instance for this demo.
    #
    # @return [Parser] parser for this demo
    def parser
      Parser.new(self, :mode=>mode)
    end

    # Run demo through {Evaluator} instance with given observers.
    def run(options={})
      Evaluator.run(self, options)
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
