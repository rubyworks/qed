module QED

  #require 'qed/config'
  require 'qed/script'

  # = Demonstration Run-time Session
  #
  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Demonstration files.
    attr :demos

    # Output format.
    attr_accessor :format

    # Trace mode
    attr_accessor :trace

    # New demonstration
    def initialize(demos, options={})
      require_reporters

      @demos  = [demos].flatten

      @format = :dotprogress
      @trace  = false

      options.each do |k,v|
        __send__("#{k}=", v) if v
      end
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use Plugin library.
    def require_reporters
      Dir[File.dirname(__FILE__) + '/reporter/*'].each do |file|
        require file
      end
    end

    # Instance of selected Reporter subclass.
    def reporter
      @reporter ||= (
        name = Reporter.constants.find{ |c| /#{format}/ =~ c.downcase }
        Reporter.const_get(name).new(:trace => trace)
      )
    end

    #
    #def scope
    #  @scope ||= Scope.new
    #end

    #
    def scripts
      @scripts ||= demos.map{ |demo| Script.new(demo) }
    end

    #
    def observers
      [reporter]
    end

    # Run session.
    def run
      #profile.before_session(self)
      reporter.before_session(self)
      #demos.each do |demo|
      #  script = Script.new(demo, report)
      scripts.each do |script|
        script.run(*observers)
      end
      reporter.after_session(self)
      #profile.after_session(self)
    end

    # Globally applicable advice.
    #def environment
    #  scripts.each do |script|
    #    script.require_environment
    #  end
    #end

  end#class Session

end#module QED

