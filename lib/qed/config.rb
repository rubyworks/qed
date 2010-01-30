module QED

  # Setup global configuration.
  #
  #   QED.config do
  #
  #     Before(:session) do
  #       # ...
  #     end
  #
  #     After(:session) do
  #       # ...
  #     end
  #
  #   end
  #
  def self.config(&block)
    @config ||= Config.new
    @config.instance_eval(&block) if block
    @config
  end

  #
  class Config

    #
    def initialize
      @local = ['test/demos', 'demos', 'qed']
  
      @before = { :session=>[], :demo=>[], :step=>[] }
      @after  = { :session=>[], :demo=>[], :step=>[] }

      if file = Dir.glob('{.,}config/qed.{yml,yaml}').first
        YAML.load(File.new(file)).each do |k,v|
          __send__("#{k}=", v)
        end
      end
    end

    #
    attr_accessor :local

    #
    def Before(type=:step, &procedure)
      @before[type] << procedure if procedure
      @before[type]
    end

    #
    def After(type=:step, &procedure)
      @after[type] << procedure if procedure
      @after[type]
    end

  end

end
