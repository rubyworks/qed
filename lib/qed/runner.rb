module QED

  require 'qed/script'

  # = Demonstration Runner
  #
  # The Runner class loops through a set of demonstrations
  # and executes each one in turn.
  #
  # The current working directory is changed to that of the
  # demonstration script's. So any relative file references
  # within a demo must take that into account.
  #
  class Runner

    #def self.configure(plugin=nil, &block)
    #  if block_given?
    #    m = Module.new(&block)
    #    m.extend m
    #    @config << m
    #  end
    #  if plugin
    #    @config << plugin
    #  end
    #end

    #def self.configure(&block)
    #  class_eval(&block)
    #end

    #def self.start(&block)
    #  define_method(:start, &block)
    #end

    #def self.finish(&block)
    #  define_method(:finish, &block)
    #end

    #
    attr :demos

    #
    attr_accessor :format

    #
    attr_accessor :trace

    #attr :context
    #attr :count

    #attr_accessor :before
    #attr_accessor :after

    # New demonstration
    def initialize(demos, options={})
      @demos       = [demos].flatten

      @format      = :dotprogress
      @trace       = false

      options.each do |k,v|
        __send__("#{k}=", v) if v
      end
    end

    # Instance of selected Reporter subclass.
    def reporter
      case format
      when :html
        Reporter::Html.new(reporter_options)
      when :dotprogress
        Reporter::DotProgress.new(reporter_options)
      when :verbatim
        Reporter::Verbatim.new(reporter_options)
      when :summary
        Reporter::Summary.new(reporter_options)
      else
        Reporter::DotProgress.new(reporter_options)
      end
    end

    # Report options.
    #--
    # TODO: rename :verbose to :trace
    #++
    def reporter_options
      { :verbose => @trace }
    end

    #
    def output
      @output ||= reporter
    end

    #
    def check
      QED.Before(:run).each{ |f| f.call }
      output.report_intro
      demos.each do |demo|   # loop through each demo
        run_demo(demo)       # run the demo
      end
      output.report_summary
      QED.After(:run).each{ |f| f.call }
    end

    # Run a demonstration.
    def run_demo(demo)
      script = Script.new(demo, output)
      #Dir.chdir(File.dirname(demo)) do
        script.run
      #end
    end

=begin
    # Run a demonstration step.
    #
    def run_step(demo, step)
      output.report_step(step)
      # TODO: Would demo.before + demo.code be better?
      context.instance_eval(@before, demo.file) if @before
      begin
        context.instance_eval(step.code, demo.file, step.lineno)
        output.report_pass(step)
      rescue Assertion => error
        output.report_fail(step, error)
      rescue Exception => error
        output.report_error(step, error)
      ensure
        context.instance_eval(@after, demo.file) if @after
      end
    end

    # Run a demonstration tabular step.
    #
    # TODO: Table reporting needs to be improved. Big time!
    def run_table(demo, step)
      table = YAML.load(File.new(step.file))  # yaml or csv ?

      vars = *table[0]
      rows = table[1..-1]

      output.report_step(step)
      context.instance_eval(@before, demo.file) if @before
      rows.each do |row|
        set  = vars.zip(row).map{ |a| "#{a[0]}=#{a[1].indemot}" }.join(';')
        code = set + "\n" + step.code
        begin
          context.instance_eval(code, demo.file, step.lineno)
          #output.report_literal(set)
          output.report_pass(step)
        rescue Assertion => error
          output.report_fail(step, error)
        rescue Exception => error
          output.report_error(step, error)
        ensure
          context.instance_eval(@after, demo.file) if @after
        end
      end
    end
=end

  end#class Runner

end#module QED

