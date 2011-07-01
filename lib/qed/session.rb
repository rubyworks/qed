module QED

  require 'qed/settings'
  require 'qed/demo'

  # The Session class encapsulates a set of demonstrations 
  # and the procedure for looping through them and running
  # each in turn.
  #
  class Session

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

      @files     = [files].flatten

      @format    = options[:format]   || :dotprogress
      @trace     = options[:trace]    || false
      @mode      = options[:mode]     || nil
      @profile   = options[:profile]  || :default
      @loadpath  = options[:loadpath] || []
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
    #--
    # TODO: Pass settings to demo, so we can get temporary_dirctory.
    #++
    def demos
      @demos ||= demo_files.map{ |file| Demo.new(file, :mode=>mode, :at=>directory) }
    end

    #
    def observers
      [reporter]
    end

    # Run session.
    #--
    # TODO: remove loadpath additions when done
    #++
    # COMMIT: Pre-parse demos before running them.
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
    end

    #
    def clear_directory
      settings.clear_directory
    end

    # Add to load path (from -I option).
    def prepare_loadpath
      loadpath.each{ |dir| $LOAD_PATH.unshift(dir) }
    end

    # Require libraries (from -r option).
    def require_libraries
      requires.each{ |file| require(file) }
    end

    #
    def require_profile
      settings.require_profile(profile)
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
      demos_gather(DEMO_TYPES)
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
      files = files.reject{ |f| f =~ Regexp.new('\/'+omit.join('|')+'\/') }
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

    #
    def self.cli(*argv)
      require 'optparse'
      require 'shellwords'

      files, options = cli_parse(argv)

      if files.empty?
        puts "No files."
        exit -1
      end

      session = new(files, options)
      session.run
    end

    # Instance of OptionParser
    def self.cli_parse(argv)
      options = {}
      options_parser = OptionParser.new do |opt|
        opt.banner = "Usage: qed [options] <files...>"

        opt.separator("Custom Profiles:") unless settings.profiles.empty?

        settings.profiles.each do |name, value|
          o = "--#{name}"
          opt.on(o, "#{name} custom profile") do
            options[:profile] = name.to_sym
          end
        end

        opt.separator("Report Formats (pick one):")
        opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
          options[:format] = :dotprogress
        end
        opt.on('--verbatim', '-v', "use verbatim reporter") do
          options[:format] = :verbatim
        end
        opt.on('--tapy', '-y', "use TAP-Y reporter") do
          options[:format] = :tapy
        end
        opt.on('--bullet', '-b', "use bullet-point reporter") do
          options[:format] = :bullet
        end
        opt.on('--html', '-h', "use underlying HTML reporter") do
          options[:format] = :html
        end
        #opt.on('--script', "psuedo-reporter") do
        #  options[:format] = :script  # psuedo-reporter
        #end
        opt.on('--format', '-f FORMAT', "use custom reporter") do |format|
          options[:format] = format.to_sym
        end

        opt.separator("Control Options:")
        opt.on('--comment', '-c', "run comment code") do
          options[:mode] = :comment
        end
        opt.on('--profile', '-p NAME', "load runtime profile") do |name|
          options[:profile] = name
        end
        opt.on('--loadpath', "-I PATH", "add paths to $LOAD_PATH") do |paths|
          options[:loadpath] = paths.split(/[:;]/).map{|d| File.expand_path(d)}
        end
        opt.on('--require', "-r LIB", "require library") do |paths|
          options[:requires] = paths.split(/[:;]/)
        end
        opt.on('--rooted', '-R', "run from project root instead of temporary directory") do
          options[:rooted] = true
        end
        # COMMIT:
        #   The qed command --trace option takes a count.
        #   Use 0 to mean all.
        opt.on('--trace', '-t [COUNT]', "show full backtraces for exceptions") do |cnt|
          #options[:trace] = true
          ENV['trace'] = cnt
        end
        opt.on('--warn', "run with warnings turned on") do
          $VERBOSE = true # wish this were called $WARN!
        end
        opt.on('--debug', "exit immediately upon raised exception") do
          $DEBUG   = true
        end

        opt.separator("Optional Commands:")
        opt.on_tail('--version', "display version") do
          puts "QED #{QED::VERSION}"
          exit
        end
        opt.on_tail('--copyright', "display copyrights") do
          puts "Copyright (c) 2008 Thomas Sawyer, Apache 2.0 License"
          exit
        end
        opt.on_tail('--help', '-h', "display this help message") do
          puts opt
          exit
        end
      end
      options_parser.parse!(argv)
      return argv, options
    end

    # TODO: Pass to Session class, instead of acting global.
    # It is used at the class level to get profiles for the cli.
    def self.settings
      @settings ||= Settings.new
    end

  end#class Session

end#module QED
