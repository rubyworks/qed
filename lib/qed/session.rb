module QED

  require 'qed/settings'
  require 'qed/demo'

  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

    # If files are not specified than these directories 
    # will be searched.
    DEFAULT_FILES = ['qed', 'demo', 'spec']

    # Default recognized demos file types.
    DEMO_TYPES = %w{qed rdoc md markdown}

    #
    CODE_TYPES = %w{rb}

    # Directory names to omit from automatic selection.
    OMIT_PATHS = %w{applique helpers support sample samples fixture fixtures}

    # Demonstration files (or globs).
    attr_reader :files

    # File patterns to omit.
    attr_accessor :omit

    # Output format.
    attr_accessor :format

    # Trace execution?
    attr_accessor :trace

    # Parse mode.
    attr_accessor :mode

    # Paths to be added to $LOAD_PATH.
    attr_reader :loadpath

    # Libraries to be required.
    attr_reader :requires

    # Operate from project root?
    attr_accessor :rooted

    # Selected profile.
    attr_accessor :profile

    # Returns instance of Settings class.
    attr :settings

    # New Session
    def initialize(files, options={})
      require_reporters

      @files = [files].flatten.compact
      @files = [DEFAULT_FILES.find{ |d| File.directory?(d) }] if @files.empty?
      @files = @files.compact

      @format    = options[:format]   || :dotprogress
      @trace     = options[:trace]    || false
      @mode      = options[:mode]     || nil
      @profile   = options[:profile]  || :default
      @loadpath  = options[:loadpath] || ['lib']
      @requires  = options[:requires] || []

      @omit      = OMIT_PATHS  # TODO: eventually make configurable

      @settings  = Settings.new(options)
    end

    #
    def directory
      settings.tmpdir
    end

    # Top-level configuration.
    #def config
    #  QED.config
    #end

    # TODO: Ultimately use Plugin library to support custom reporters?

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
        Reporter.const_get(name).new(:trace => trace)
      )
    end

    # TODO: Pass settings to demo, so we can get temporary_directory.

    # Returns an Array of Demo instances.
    def demos
      @demos ||= demo_files.map{ |file| Demo.new(file, :mode=>mode, :at=>directory) }
    end

    #
    def observers
      [reporter]
    end

    # TODO: remove loadpath additions when done

    # Run session.
    def run
      abort "No documents." if demo_files.empty?

      clear_directory

      prepare_loadpath
      require_libraries

      require_profile  # TODO: here or in chdir?

      Dir.chdir(directory) do
        # pre-parse demos
        demos.each do |demo|
          demo.steps
        end

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

      reporter.success?
    end

    #
    def clear_directory
      settings.clear_directory
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
    def require_profile
      settings.load_profile(profile)
    end

    # Returns a list of demo files. The files returned depends on the
    # +files+ attribute and if none given, then the current run mode.
    def demo_files
      @demo_files ||= (
        if mode == :comment
          demos_in_comment_mode
        else
          demos_in_normal_mode
        end
      )
    end

    # Collect default files to process in normal demo mode.
    def demos_in_normal_mode
      demos_gather #(DEMO_TYPES)
    end

    # Collect default files to process in code comment mode.
    #
    # TODO: Sure removing applique files is the best approach here?
    def demos_in_comment_mode
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

    #
    def total_step_count
      count = 0
      QED.all_steps.each do |step|
        count += 1 unless step.header?
      end
      count
    end

  end#class Session

end#module QED
