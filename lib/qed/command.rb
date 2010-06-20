#!/usr/bin/env ruby

require 'qed'
require 'optparse'
require 'shellwords'

module QED

  # = QED Commandline Tool
  #
  class Command

    # Configuration directory `.qed`, `.config/qed` or `config/qed`.
    # In this directory special configuration files can be placed
    # to autmatically effect qed execution. In particular you can
    # add a `profiles.yml` file to setup convenient execution
    # scenarios.
    CONFDIR = "{.,.config/,config/}qed"

    # Default location of demonstrations if no specific files
    # or locations given. This is use in Dir.glob. The default
    # locations are qed/, demo/ or demos/, searched for in that
    # order.
    DEFAULT_DEMO_LOCATION = '{qed,demo,demos}'

    # Instantiate a new Command object and call #execute.
    def self.execute
      new.execute
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

    # Returns a list of demo files.
    def demos
      files = self.files
      types = %w{qed rdoc md markdown}
      if files.empty?
        files << DEFAULT_DEMO_LOCATION
      end
      files = files.map do |pattern|
        Dir[pattern]
      end.flatten.uniq
      files = files.map do |file|
        if File.directory?(file)
          Dir[File.join(file,'**','*.{' + types.join(',') + '}')]
        else
          file
        end
      end
      files = files.flatten.uniq.sort
      #files = files.select do |file| 
      #  %w{.yml .yaml .rb}.include?(File.extname(file))
      #end
      files
    end

    # Session instance.
    def session
      @session ||= Session.new(demos, :format=>format, :trace=>trace)
    end

    # Parse command-line options along with profile options.
    def parse
      @files = []
      argv = ARGV.dup
      opts.parse!(argv)
      @files.concat(argv)

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
    def execute
      parse

      abort "No documents." if demos.empty?

      prepare_loadpath

      require_libraries
      require_profile

      session.run
    end

    # Profile configurations.
    def profiles
      @profiles ||= (
        file = Dir["#{root}/#{CONFDIR}/profile{,s}.{yml,yaml}"].first
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
      return unless root
      if file = Dir["#{root}/#{CONFDIR}/#{extension}.rb"].first
        require(file)
      end
    end

    # Project root directory.
    def root
      QED.root
    end

  end

  # Locate project's root directory by searching for a README file.
  #
  # TODO: Is there no perfect way to find root directory of a project?
  # If not then perhaps we should base root off the working directory?
  def self.root(path=nil)
    path ||= Dir.pwd
    path = File.dirname(path) unless File.directory?(path)
    until path == File.dirname(path)
      mark = Dir.glob(File.join(path, '{.qed,.config/qed,config/qed,README*}'),File::FNM_CASEFOLD).first
      return path if mark
      path = File.dirname(path)
    end
    nil
  end

end

