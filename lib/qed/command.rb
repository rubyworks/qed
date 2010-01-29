#!/usr/bin/env ruby

require 'qed'
require 'optparse'
require 'shellwords'
require 'tilt'

module QED

  # = QED Commandline Tool
  #
  class Command

    # Configuration directory.
    CONFDIR = "{.,}config/qed"

    # Initialize and execute.
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

    #
    def files=(globs)
      @files = [globs].flatten
    end

    #
    attr_accessor :loadpath

    #
    attr_accessor :requires

    #
    attr_accessor :env

    #

    def initialize
      @format   = nil
      @env      = nil
      @profile  = nil
      @requires = []
      @loadpath = []
      @files    = []
      @options  = {}
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

        opt.separator("Report Options (pick one):")

        opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
          @options[:format] = :dotprogress
        end

        opt.on('--html', '-h', "use HTML reporter") do
          @options[:format] = :html
        end

        opt.on('--verbatim', '-v', "use verbatim reporter") do
          @options[:format] = :verbatim
        end

        opt.on('--summary', '-s', "use summary reporter") do
          @options[:format] = :summary
        end

        opt.on('--script', "psuedo-reporter") do
          @options[:format] = :script  # psuedo-reporter
        end

        opt.separator("Control Options:")

        opt.on('--env', '-e [NAME]', "runtime environment [default]") do |name|
          @options[:env] = name
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

    #

    def demos
      files = self.files
      types = Tilt.mappings.keys
      if files.empty?
        files << '{demo,test/demo}{s,}'
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
      files = files.flatten.uniq
      #files = files.select do |file| 
      #  %w{.yml .yaml .rb}.include?(File.extname(file))
      #end
      files
    end

    # Instance of Runner class.

    def runner
      Runner.new(demos, :format=>format, :trace=>trace)
    end

    # Parse command-line options along with profile options.

    def parse
      @files = []
      argv = ARGV.dup
      opts.parse!(argv)
      @files.concat(argv)

      if profile
        args = profiles[profile]
        argv = Shellwords.shellwords(args)
        opts.parse!(argv)
        @files.concat(argv)
      end

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
      require_environment

      # TODO: Remove case, can :script be done with Reporter or do we ne need selectable Runner?
      case format
      when :script
        demos.each do |spec|
          puts spec.to_script
        end
      else
        runner.check
      end
    end

    # Profile configurations.

    def profiles
      @profiles ||= (
        file = Dir["#{CONFDIR}/profile{,s}.{yml,yaml}"].first
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

    # Require requirement file (from -e option.

    def require_environment
      if env
        if file = Dir["#{CONFDIR}/{env,environments}/#{env}.rb"].first
          require(file)
        end
      else
        if file = Dir["#{CONFDIR}/env.rb"].first
          require(file)
        elsif file = Dir["#{CONFDIR}/{env,environments}/default.rb"].first
          require(file)
        end
      end
    end

  end

end

