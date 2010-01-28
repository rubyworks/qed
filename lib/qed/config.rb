module QED

  class Config

    def initialize
      @local = ['qed', 'demos', 'test/demos']

      if file = File.glob('{.,}config/qed.{yml,yaml}')
        YAML.load(File.new(file)).each do |k,v|
          __send__("#{k}=", v)
        end
      end
    end

    attr_accessor :local

    # How ot identify a header?
    #attr_accessor :header

    # How ot identify a footer?
    #attr_accessor :footer

  end

end
