require 'optparse'
require 'shellwords'
require 'fileutils'

module QED

  def self.main(*argv)
    Command.main(*argv)
  end

  # QED Command-line tool.
  #
  # TODO: Merge Command with Session ?
  class Command

    # Configuration directory `.qed`, `.config/qed` or `config/qed`.
    # In this directory special configuration files can be placed
    # to autmatically effect qed execution. In particular you can
    # add a `profiles.yml` file to setup convenient execution
    # scenarios.
    CONFIG_PATTERN = "{.,.config/,config/}qed"

    ## Default location of demonstrations if no specific files
    ## or locations given. This is use in Dir.glob. The default
    ## locations are qed/, demo/ or demos/, searched for in that
    ## order relative to the root directory.
    ##--
    ## TODO: deprecate this
    ##++
    ##DEMO_LOCATION = '{qed,demo,demos}'

    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.ruby,.git/,.hg/,_darcs/,.qed/,.config/qed/,config/qed/}'

    # Directory names to omit from automatic selection.
    OMIT_PATHS = %w{applique helpers support sample samples fixture fixtures}

    # Home directory.
    HOME = File.expand_path('~')

    # Default recognized demos file types.
    DEMO_TYPES = %w{qed rdoc md markdown}

    #
    CODE_TYPES = %w{rb}

    # Instantiate a new Command object and call #execute.
    def self.main(*argv)
      new.execute(argv)
    end

    # Ouput format.
    attr :format

    # Make sure format is a symbol.
    def format=(type)
      @format = type.to_sym
    end

    # Trace execution?
    attr :trace

    # Options defined by selected profile.
    attr :profile

    # Command-line options.
    #attr :options

    # Files to be run.
    attr_reader :files

    # Ensure files are in a flat list.
    def files=(globs)
      @files = [globs].flatten
    end

    # Paths to be added to $LOAD_PATH.
    attr_accessor :loadpath

    # Libraries to be required.
    attr_accessor :requires

    # Move to root directory?
    attr_accessor :root

    # Parse mode.
    attr_accessor :mode

    #
    attr_accessor :omit

    #
    # TODO: Should extension and profile have a common reference?
    def initialize
      @format    = :dotprogress
      #@extension = :default
      @profile   = :default
      @requires  = []
      @loadpath  = []
      @files     = []
      #@options   = {}

      @omit      = OMIT_PATHS
    end

    # Instance of OptionParser
    def opts
      @opts ||= OptionParser.new do |opt|
        opt.banner = "Usage: qed [options] <files...>"

        opt.separator("Custom Profiles:") unless profiles.empty?

        profiles.each do |name, value|
          o = "--#{name}"
          opt.on(o, "#{name} custom profile") do
            self.profile = name
          end
        end

        opt.separator("Report Formats (pick one):")
        opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
          self.format = :dotprogress
        end
        opt.on('--verbatim', '-v', "use verbatim reporter") do
          self.format = :verbatim
        end
        opt.on('--bullet', '-b', "use bullet-point reporter") do
          self.format = :bullet
        end
        opt.on('--html', '-h', "use underlying HTML reporter") do
          self.format = :html
        end
        #opt.on('--script', "psuedo-reporter") do
        #  self.format = :script  # psuedo-reporter
        #end
        opt.on('--format', '-f FORMAT', "use custom reporter") do |format|
          self.format = format
        end
        opt.separator("Control Options:")
        opt.on('--root', '-R', "run from alternate directory") do |path|
          self.root = path
        end
        opt.on('--comment', '-c', "Run comment code.") do
          self.mode = :comment
        end
        opt.on('--profile', '-p NAME', "load runtime profile") do |name|
          self.profile = name
        end
        opt.on('--loadpath', "-I PATH", "add paths to $LOAD_PATH") do |paths|
          self.loadpath = paths.split(/[:;]/).map{|d| File.expand_path(d)}
        end
        opt.on('--require', "-r LIB", "require library") do |paths|
          self.requires = paths.split(/[:;]/)
        end
        opt.on('--trace', '-t', "show full backtraces for exceptions") do
          self.trace = true
        end
        opt.on('--debug', "exit immediately upon raised exception") do
          $VERBOSE = true # wish this were called $WARN
          $DEBUG   = true
        end
        opt.separator("Optional Commands:")
        opt.on_tail('--version', "display version") do
          puts "QED #{VERSION}"
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
    end

    # Returns a list of demo files. The files returned depends on the
    # +files+ attribute and if none given, then the current run mode.
    def demos
      @demos ||= (
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

    # Parse command-line options along with profile options.
    def parse(argv)
      #@files = []
      opts.parse!(argv ||= ARGV.dup)
      #@files.concat(argv)
      @files = argv

      if @files.empty?
        puts "No files."
        puts opts
        exit
      end

      #if profile
      #if args = profiles[profile]
      #  argv = Shellwords.shellwords(args)
      #  opts.parse!(argv)
      #  @files.concat(argv)
      #end
      #end

      #options.each do |k,v|
      #  __send__("#{k}=", v)
      #end
    end

    # Run demonstrations.
    def execute(argv)
      parse(argv)

      abort "No documents." if demos.empty?

      prepare_loadpath
      require_libraries

      require_profile  # TODO: here or in chdir?

      jump = root || temporary_directory

      Dir.chdir(jump) do
        session.run
      end
    end

    # Session instance.
    def session
      @session ||= Session.new(demos, :format=>format, :trace=>trace, :mode=>mode)
    end

    # Project's root directory.
    def root_directory
      @root_directory ||= find_root
    end

    # Project's QED configuation directory.
    def config_directory
      @config_directory ||= find_config #Dir[File.join(root_directory, CONFIG_PATTERN)].first
    end

    # Profile configurations.
    def profiles
      @profiles ||= (
        files = Dir["#{config_directory}/*.rb"]
        files.map do |file|
          File.basename(file).chomp('.rb')
        end
      )
    end

    # Add to load path (from -I option).
    def prepare_loadpath
      loadpath.each{ |dir| $LOAD_PATH.unshift(dir) }
    end

    # Require libraries (from -r option).
    def require_libraries
      requires.each{ |file| require(file) }
    end

    # Require requirement file (from -e option).
    def require_profile
      return unless config_directory
      if file = Dir["#{config_directory}/#{profile}.rb"].first
        require(file)
      end
    end

    #
    def temporary_directory
      @temporary_directory ||= (
        dir = File.join(root_directory, 'tmp', 'qed')
        FileUtils.mkdir_p(dir)
        dir
      )
    end

    # Locate project's root directory. This is done by searching upward
    # in the file heirarchy for the existence of one of the following
    # path names, each group being tried in turn.
    #
    # * .git/
    # * .hg/
    # * _darcs/
    # * .config/qed/
    # * config/qed/
    # * .qed/
    # * .ruby
    #
    # Failing to find any of these locations, resort to the fallback:
    # 
    # * lib/
    #
    def find_root(path=nil)
      path = File.expand_path(path || Dir.pwd)
      path = File.dirname(path) unless File.directory?(path)

      root = lookup(ROOT_PATTERN, path)
      return root if root

      #root = lookup(path, '{.qed,.config/qed,config/qed}/')
      #return root if root

      #root = lookup(path, '{qed,demo,demos}/')
      #return root if root

      root = lookup('lib/', path)
      return root if root

      abort "QED failed to resolve project's root location.\n" +
            "QED looks for following entries to identify the root:\n" +
            "  .config/qed/\n" +
            "  config/qed/\n" +
            "  .qed/\n" +
            "  .ruby\n" +
            "  lib/\n" +
            "Please add one of them to your project to proceed."
    end

    # Locate configuration directory by seaching up the 
    # file hierachy relative to the working directory
    # for one of the following paths:
    #
    # * .config/qed/
    # *  config/qed/
    # * .qed/
    #
    def find_config
      Dir[File.join(root_directory,CONFIG_PATTERN)].first
    end

    # Lookup path +glob+, searching each higher directory
    # in turn until just before the users home directory
    # is reached or just before the system's root directory.
    #
    # TODO: include HOME directory in search?
    def lookup(glob, path=Dir.pwd)
      until path == HOME or path == '/' # until home or root
        mark = Dir.glob(File.join(path,glob), File::FNM_CASEFOLD).first
        return path if mark
        path = File.dirname(path)
      end
    end

  end

end
