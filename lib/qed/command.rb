#!/usr/bin/env ruby

require 'qed'
require 'optparse'

module QED

  # = QED Commandline Tool
  #
  class Command

    #
    def self.execute
      new.execute
    end

    #

    attr :format

    #

    attr :trace

    #

    attr :profile

    #

    def initialize
      @format   = nil
      @requires = []
      @loadpath = []
      @profile  = {}
    end

    # Instance of OptionParser

    def opts
      @opts ||= OptionParser.new do |opt|

        opt.separator("Custom Profiles:") if config

        config.to_a.each do |useropt, action|
          next if useropt == 'all'
          o = "--#{useropt}"
          opt.on(o, "#{useropt} custom profile") do
            @profile = config[useropt]
          end        
        end

        opt.separator("Report Options (pick one):")

        opt.on('--dotprogress', '-d', "use dot-progress reporter [default]") do
          @format = :summary
        end

        opt.on('--verbatim', '-v', "use verbatim reporter") do
          @format = :verbatim
        end

        opt.on('--summary', '-s', "use summary reporter") do
          @format = :summary
        end

        opt.on('--script', "psuedo-reporter") do
          @format = :script  # psuedo-reporter
        end

        opt.separator("Control Options:")

        opt.on('--loadpath', "-I", "add paths to $LOAD_PATH") do |arg|
          @loadpath.concat(arg.split(/[:;]/).map{ |dir| File.expand_path(dir) })
        end

        opt.on('--require', "-r", "require library") do |arg|
          @requires.concat(arg.split(/[:;]/)) #.map{ |dir| File.expand_path(dir) })
        end

        opt.on('--trace', '-t', "show full backtraces for exceptions") do
          @trace = true
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

    def config
      @config ||= load_rc
    end

    #

    def common
      @common ||= config['all']
    end

    # Load the YAML runtime configuration file.

    def load_rc
      if rcfile = Dir['{,.}config/qed.yml'].first
        YAML.load(File.new(rcfile))
      else
        {}
      end
    end

    #

    def demos
      demo_files
    end

    #

    def demo_files
      files = ARGV.map do |pattern|
        Dir[pattern]
      end.flatten.uniq

      files = files.map do |file|
        if File.directory?(file)
          Dir[File.join(file,'**','*{.qed,.rd,.rdoc,.md,.markdown}')]
        else
          file
        end
      end

      file = files.flatten.uniq

      #files = files.select do |file| 
      #  %w{.yml .yaml .rb}.include?(File.extname(file))
      #end

      files
    end

    # Instance of selected Reporter subclass.

    def reporter
      case format
      when :dotprogress
        Reporter::DotProgress.new(reporter_options)
      when :verbatim
        Reporter::Verbatim.new(reporter_options)
      when :summary
        Reporter::Summary.new(reporter_options)
      else
        nil
      end
    end

    # TODO: rename :verbose to :trace

    def reporter_options
      { :verbose => @trace }
    end

    # Instance of Runner class.

    def runner
      Runner.new(demos, reporter)
    end

    # Run demonstrations.

    def execute
      opts.parse!

      common_configure
      profile_configure

      prepare_loadpath
      require_libraries

      common_setup
      profile_setup

      case reporter
      when :script
        specs.each do |spec|
          puts spec.to_script
        end
      else
        runner.check
      end

      profile_finish
      common_finish
    end


    #
    def common_configure
      files = common['loadpath'] || []
      @loadpath.concat(files)
      files = common['require'] || common['requires'] || []
      @requires.concat(files)
      @format = profile['format'].to_sym if profile['format']
    end

    #

    def profile_configure
      files = profile['loadpath'] || []
      @loadpath.concat(files)
      files = profile['require'] || profile['requires'] || []
      @requires.concat(files)
      @format = profile['format'].to_sym if profile['format']
    end

    #

    def common_setup
      eval common['setup'] if common['setup']
    end

    #

    def profile_setup
      eval(profile['setup']) if profile['setup']
    end

    #

    def profile_finish
      eval(profile['finish']) if profile['finish']
    end

    #

    def common_finish
      eval(common['finish'])  if common['finish']
    end

    #

    def prepare_loadpath
      @loadpath.each{ |dir| $LOAD_PATH.unshift(dir) }
    end

    #

    def require_libraries
      @requires.each{ |file| require(file) }
    end


    # TODO: Better way to load helpers?
    #
    #def load_helpers
    #  dirs = spec_files.map{ |file| File.join(Dir.pwd, File.dirname(file)) }
    #  dirs = dirs.select{ |dir| File.directory?(dir) }
    #  dirs.each do |dir|
    #    while dir != '/' do
    #      helper = File.join(dir, 'qed_helper.rb')
    #      load(helper) if File.exist?(helper)
    #      break if Dir.pwd == dir
    #      dir = File.dirname(dir)
    #    end
    #  end
    #end

  end
end

