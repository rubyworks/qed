require 'qed/domain_language'

module QED

  # Scope is the context in which QED documents are run.

  class Scope < Module
 
    #
    def self.new(applique)
      @applique = applique
      super
    end

    #
    def self.const_missing(name)
      @applique.const_get(name)
    end

    #
    def initialize(applique)
      super()
      @applique = applique
      extend self
      extend applique
    end

    #
    def __binding__
      @__binding__ ||= binding
    end

    #
    def eval(code)
      super(code, __binding__)
    end

    #
    def When(*patterns, &procedure)
      @applique.When(*patterns, &procedure)
    end

    #
    def Before(type=:code, &procedure)
      @applique.Before(type, &procedure)
    end

    #
    def After(type=:code, &procedure)
      @applique.After(type, &procedure)
    end

    # Table-based steps.
    #--
    # TODO: Utilize HTML table element for tables.
    #++
    def Table(file=nil, &blk)
      file = file || @_tables.last
      tbl = YAML.load(File.new(file))
      tbl.each do |set|
        blk.call(*set)
      end
      @__tables__ ||= []
      @__tables__ << file
    end

    # Read/Write a static data fixture.
    #--
    # TODO: Perhaps #Data would be best as some sort of Kernel extension.
    #++
    def Data(file, &content)
      raise if File.directory?(file)
      if content
        FileUtils.mkdir_p(File.dirname(fname))
        case File.extname(file)
        when '.yml', '.yaml'
          File.open(file, 'w'){ |f| f << content.call.to_yaml }
        else
          File.open(file, 'w'){ |f| f << content.call }
        end
      else
        #raise LoadError, "no such fixture file -- #{fname}" unless File.exist?(fname)
        case File.extname(file)
        when '.yml', '.yaml'
          YAML.load(File.new(file))
        else
          File.read(file)
        end
      end
    end

    #include DomainLanguage

    #def initialize
    #  @__binding__ = binding
    #end

    #def __binding__
    #  @__binding__
    #end
  end

end


