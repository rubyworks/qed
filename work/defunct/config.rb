module QED

=begin
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
  def self.configure(&block)
    @config ||= Profile.new #(nil)
    @config.instance_eval(&block) if block
    @config
  end
=end

  #
  class Profile

    #
    def initialize
      #@local = ['test/demos', 'demos', 'qed']
  
      @before = { :session=>[], :demo=>[], :step=>[] }
      @after  = { :session=>[], :demo=>[], :step=>[] }

      #if file = Dir.glob('{.,}config/qed.{yml,yaml}').first
      #  YAML.load(File.new(file)).each do |k,v|
      #    __send__("#{k}=", v)
      #  end
      #end
    end

    #
    #attr_accessor :local

    #
    def Before(type=:session, &procedure)
      @before[type] << procedure if procedure
      @before[type]
    end

    #
    def After(type=:session, &procedure)
      @after[type] << procedure if procedure
      @after[type]
    end

  end

end

