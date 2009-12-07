#!/usr/bin/env ruby

require 'qed'
require 'optparse'

module QED

  # = QED Commandline Tool
  #
  class Command
    def self.execute
      new.execute
    end

    #
    attr :format

    #
    def initialize
      @format = nil
    end

    # Instance of OptionParser
    def opts
      @opts ||= OptionParser.new do |opt|

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

        opt.on('--loadpath', "-I", "add paths to $LOAD_PATH") do |arg|
          libs = arg.split(/[:;]/).map{ |dir| File.expand_path(dir) }
          libs.each{|dir| $LOAD_PATH.unshift(dir)}
        end

        opt.on('--verbose', '-V', "extra verbose output") do
          @verbose = true
          $VERBOSE = true
        end

        opt.on('--debug', "demos will exit on error") do
          $DEBUG = true
        end

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
    #def load_rc
    #  if rcfile = Dir['.config/qed{,rc}{,.rb}'].first
    #    load(rcfile)
    #  end
    #end

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
        File.directory?(file) ? Dir[File.join(file,'**','*')] : file
      end.flatten.uniq

      files = files.reject do |file| 
        %w{.yml .yaml .rb}.include?(File.extname(file))
      end

      files
    end

    #
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

    #
    def reporter_options
      { :verbose => @verbose }
    end

    #
    def runner
      Runner.new(demos, reporter)
    end

    #
    def execute
      opts.parse!
      #load_rc
      #load_helpers
      case reporter
      when :script
        specs.each do |spec|
          puts spec.to_script
        end
      else
        runner.check
      end
    end

  end
end

