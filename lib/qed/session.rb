module QED

  require 'qed/config'
  require 'qed/script'

  # = Demonstration Run-time Session
  #
  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Demo file globs.
    attr :demos

    # Output format.
    attr_accessor :format

    # Trace mode
    attr_accessor :trace

    #attr :count

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
    def config
      QED.config
    end

    # TODO: Ultimately use Plugin library.
    def require_reporters
      Dir[File.dirname(__FILE__) + '/reporter/*'].each do |file|
        require file
      end
    end

    # Instance of selected Reporter subclass.
    def report
      @report ||= (
        name = Reporter.constants.find{ |c| /#{format}/ =~ c.downcase }
        Reporter.const_get(name).new(:trace => trace)
      )
    end

    # Run session.
    def run
      config.Before(:session).each{ |f| f.call }
      report.Before(:session, self)
      demos.each do |demo|
        script = Script.new(demo, report)
        script.run
      end
      report.After(:session, self)
      config.After(:session).each{ |f| f.call }
    end

  end#class Session

end#module QED

