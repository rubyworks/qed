require 'optparse'
require 'shellwords'

module QED

  def self.main(*argv)
    Command.main(*argv)
  end

  # = QED Commandline Tool
  #
  # TODO: Merge Command with Session ?
  class Command

    # Configuration directory `.qed`, `.config/qed` or `config/qed`.
    # In this directory special configuration files can be placed
    # to autmatically effect qed execution. In particular you can
    # add a `profiles.yml` file to setup convenient execution
    # scenarios.
    CONFIG_PATTERN = "{.,.config/,config/}qed"

    # Default location of demonstrations if no specific files
    # or locations given. This is use in Dir.glob. The default
    # locations are qed/, demo/ or demos/, searched for in that
    # order relative to the root directory.
    DEMO_LOCATION = '{qed,demo,demos}'

    # Glob pattern used to search for project's root directory.
    ROOT_PATTERN = '{.root,.git,.hg,_darcs}/'

    # Home directory.
    HOME = File.expand_path('~')

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
    attr :options

    # Files to be run.
    attr :files

    # Ensure files are in a flat list.
    def files=(globs)
      @files = [globs].flatten
    end

    # Paths to be added to $LOAD_PATH.
    attr_accessor :loadpath

    # Libraries to be required.
    attr_accessor :requires

    # ?
    attr_accessor :extension

    # Move to root directory?
    attr_accessor :root

    #
    # TODO: Should extension and profile have a common reference?
    def initialize
      @format    = :dotprogress
      @extension = :default
      @profile   = :default
      @requires  = []
      @loadpath  = []
      @files     = []
      @options   = {}
    end

    # Instance of OptionParser
    def opts
      @opts ||= OptionParser.new do |opt|

        opt.separator("Custom Profiles:") unless profiles.empty?

        profiles.each do |name, value|
          o = "--#{name}"
          opt.on(o, "#{name} custom profile") do
            @profile = name
          end
        end

        opt.separator("Report Formats (pick one):")
        opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
          @options[:format] = :dotprogress
        end
        opt.on('--verbatim', '-v', "use verbatim reporter") do
          @options[:format] = :verbatim
        end
        opt.on('--bullet', '-b', "use bullet-point reporter") do
          @options[:format] = :bullet
        end
        opt.on('--html', '-h', "use underlying HTML reporter") do
          @options[:format] = :html
        end
        opt.on('--format', '-f FORMAT', "use custom reporter") do |format|
          @options[:format] = format
        end
        #opt.on('--script', "psuedo-reporter") do
        #  @options[:format] = :script  # psuedo-reporter
        #end
        opt.separator("Control Options:")
        opt.on('--root', '-R', "run command from project's root directory") do
          @options[:root] = true
        end
        opt.on('--ext', '-e NAME', "runtime extension [default]") do |name|
          @options[:extension] = name
        end
        opt.on('--loadpath', "-I PATH", "add paths to $LOAD_PATH") do |arg|
          @options[:loadpath] ||= []
          @options[:loadpath].concat(arg.split(/[:;]/).map{ |dir| File.expand_path(dir) })
        end
        opt.on('--require', "-r", "require library") do |arg|
          @options[:requires] ||= []
          @options[:requires].concat(arg.split(/[:;]/)) #.map{ |dir| File.expand_path(dir) })
        end
        opt.on('--trace', '-t', "show full backtraces for exceptions") do
          @options[:trace] = true
        end
        opt.on('--debug', "exit immediately upon raised exception") do
          $VERBOSE = true # wish this were called $WARN
          $DEBUG = true
        end
        opt.separator("Optional Commands:")
        opt.on_tail('--version', "display version") do
          puts "QED #{VERSION}"
          exit
        end
        opt.on_tail('--copyright', "display copyrights") do
          puts "Copyright (c) 2008, 2009 Thomas Sawyer, GPL License"
          exit
        end
        opt.on_tail('--help', '-h', "display this help message") do
          puts opt
          exit
        end
      end
    end

    # Default recognized demos file types.
    DEMO_TYPES = %w{qed rdoc md markdown}

    # Returns a list of demo files.
    def demos
      @demos ||= (
        files = self.files
        if files.empty?
          files << DEMO_LOCATION
        end
        files = files.map{|pattern| Dir[pattern]}.flatten.uniq
        files = files.map do |file|
          if File.directory?(file)
            Dir[File.join(file,'**','*.{' + DEMO_TYPES.join(',') + '}')]
          else
            file
          end
        end
        files = files.flatten.uniq
        files.map{|f| File.expand_path(f) }.sort
      )
    end

    # Session instance.
    def session
      @session ||= Session.new(demos, :format=>format, :trace=>trace)
    end

    # Parse command-line options along with profile options.
    def parse(argv)
      #@files = []
      opts.parse!(argv ||= ARGV.dup)
      #@files.concat(argv)
      @files = argv

      #if profile
      if args = profiles[profile]
        argv = Shellwords.shellwords(args)
        opts.parse!(argv)
        @files.concat(argv)
      end
      #end

      options.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    # Run demonstrations.
    def execute(argv)
      parse(argv)

      jump = @options[:root] ? root_directory : Dir.pwd

      Dir.chdir(jump) do
        abort "No documents." if demos.empty?

        prepare_loadpath

        require_libraries
        require_profile

        session.run
      end
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
        file = Dir["#{config_directory}/profile{,s}.{yml,yaml}"].first
        file ? YAML.load(File.new(file)) : {}
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
      if file = Dir["#{config_directory}/#{extension}.rb"].first
        require(file)
      end
    end

    # Locate project's root directory. This is done by searching upward
    # in the file heirarchy for the existence of one of the following
    # path names, each group being tried in turn.
    #
    # * .root/
    # * .git/
    # * .hg/
    # * _darcs/
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

      abort "Failed to resolve project's root location. Try adding a .root directory."
    end

    # Locate configuration directory by seaching up the 
    # file hierachy relative to the working directory
    # for one of the following paths:
    #
    # * .qed/
    # * .config/qed/
    # *  config/qed/
    #
    def find_config
      lookup(CONFIG_PATTERN)
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

