module QED

  #require 'qed/config'
  require 'qed/demo'

  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Demonstration files.
    attr :files

    # Output format.
    attr_accessor :format

    # Trace mode
    attr_accessor :trace

    #
    attr_accessor :mode

    # New Session
    def initialize(files, options={})
      require_reporters

      @files  = [files].flatten

      @mode   = options[:mode]
      @trace  = options[:trace]  || false
      @format = options[:format] || :dotprogress
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use Plugin library to support custom reporters?
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

    # Returns an Array of Demo instances.
    def demos
      @demos ||= files.map{ |file| Demo.new(file, :mode=>mode) }
    end

    #
    def observers
      [reporter]
    end

    # Run session.
    def run
      #profile.before_session(self)
      reporter.before_session(self)
      demos.each do |demo|
        demo.run(*observers)
        #pid = fork { demo.run(*observers) }
        #Process.detach(pid)
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
