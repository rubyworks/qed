module QED

  require 'qed/settings'
  require 'qed/demo'

  def self.run!(name=nil, &block)
    configure(name, &block) if block
    session  = Session.new(:profile=>name)
    success  = session.run
    exit -1 unless success
  end

  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # Default recognized demos file types.
    DEMO_TYPES = %w{qed rdoc md markdown}

    #
    CODE_TYPES = %w{rb}

    # Returns instance of Settings class.
    attr :settings

    # New Session
    def initialize(settings={})
      require_reporters

      case settings
      when Settings
        @settings = settings
      else
        @settings = Settings.new(settings)
      end
    end

    # Demonstration files (or globs).
    def files
      settings.files
    end

    # File patterns to omit.
    def omit
      settings.omit
    end

    # Output format.
    def format
      settings.format
    end

    # Trace execution?
    def trace?
      settings.trace
    end

    # Parse mode.
    def mode
      settings.mode
    end

    # Paths to be added to $LOAD_PATH.
    def loadpath
      settings.loadpath
    end

    # Libraries to be required.
    def requires
      settings.requires
    end

    # Operate from project root?
    def rooted
      settings.rooted
    end

    # Selected profile.
    def profile
      settings.profile
    end

    #
    def directory
      settings.tmpdir
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use a plugin library to support custom reporters?

    # Require all reporters.
    def require_reporters
      Dir[File.dirname(__FILE__) + '/reporter/*'].each do |file|
        require file
      end
    end

    # Instance of selected Reporter subclass.
    def reporter
      @reporter ||= (
        name = Reporter.constants.find{ |c| /#{format}/ =~ c.to_s.downcase }
        Reporter.const_get(name).new(:trace => trace?)
      )
    end

    # TODO: Pass settings to demo, so we can get temporary_directory.

    # Returns an Array of Demo instances.
    def demos
      @demos ||= demo_files.map{ |file| Demo.new(file, :mode=>mode, :at=>directory) }
    end

    # List of observers to pass to the evaluator. Only includes the reporter
    # instance, by default.
    #
    def observers
      [reporter]
    end

    # TODO: remove loadpath additions when done

    # Run session.
    def run
      abort "No documents." if demo_files.empty?

      clear_directory

      reset_assertion_counts

      #require_profile  # <-- finally runs the profile

      prepare_loadpath
      require_libraries

      Dir.chdir(directory) do
        # pre-parse demos
        demos.each{ |demo| demo.steps }

        # Let's do it.
        observers.each{ |o| o.before_session(self) }
        begin
          demos.each do |demo|
            Evaluator.run(demo, :observers=>observers, :settings=>settings) #demo.run(*observers)
            #pid = fork { demo.run(*observers) }
            #Process.detach(pid)
          end
        ensure
          observers.each{ |o| o.after_session(self) }
        end
      end

      reporter.success?
    end

    # Clear temporary testing directory.
    def clear_directory
      settings.clear_directory
    end

    # Set $ASSERTION_COUNTS to zero point.
    def reset_assertion_counts
      $ASSERTION_COUNTS = Hash.new{ |h,k| h[k] = 0 }
    end

    # Add to load path (from -I option).
    def prepare_loadpath
      loadpath.each{ |dir| $LOAD_PATH.unshift(File.expand_path(dir)) }
    end

    # Require libraries (from -r option).
    def require_libraries
      requires.each{ |file| require(file) }
    end

    #
    #def require_profile
    #  settings.load_profile(profile)
    #end

    # Returns a list of demo files. The files returned depends on the
    # +files+ attribute and if none given, then the current run mode.
    def demo_files
      @demo_files ||= (
        if mode == :comment
          demo_files_in_comment_mode
        else
          demo_files_in_normal_mode
        end
      )
    end

    # Collect default files to process in normal demo mode.
    def demo_files_in_normal_mode
      demos_gather #(DEMO_TYPES)
    end

    # Collect default files to process in code comment mode.
    #
    # TODO: Sure removing applique files is the best approach here?
    def demo_files_in_comment_mode
      files = demos_gather(CODE_TYPES)
      files = files.reject{ |f| f.index('applique/') }  # don't include applique files ???
      files
    end

    # Gather list of demo files. Uses +omit+ to remove certain files
    # based on the name of their parent directory.
    def demos_gather(extensions=DEMO_TYPES)
      files = self.files
      #files << default_location if files.empty?
      files = files.map{|pattern| Dir[pattern]}.flatten.uniq
      files = files.map do |file|
        if File.directory?(file)
          Dir[File.join(file,'**','*.{' + extensions.join(',') + '}')]
        else
          file
        end
      end
      files = files.flatten.uniq
      #files = files.reject{ |f| f =~ Regexp.new("/\/(#{omit.join('|')})\//") }
      files = files.reject{ |f| omit.any?{ |o| f.index("/#{o}/") } }
      files.map{|f| File.expand_path(f) }.uniq.sort
    end

    # Globally applicable advice.
    #def environment
    #  scripts.each do |script|
    #    script.require_environment
    #  end
    #end

    # Get the total test count. This method tallies up the number of
    # _assertive_ steps.
    #
    def total_step_count
      count = 0
      demos.each do |demo|
        demo.steps.each do |step|
          count += 1 if step.assertive?
        end
      end
      count
    end

  end#class Session

end#module QED
