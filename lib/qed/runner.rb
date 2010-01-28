module QED

  require 'qed/script'

  # = Specificaton Runner
  #
  # The Runner class loops through a set of specifications
  # and executes each one in turn.
  #
  # The current working directory is changed to that of the
  # specification script's. So any relative file references
  # within a spec must take that into account.
  #
  class Runner

    #  QED::Runner.configure do
    #    def setup(spec)
    #      ...
    #    end
    #    def teardown(spec)
    #      ...
    #    end
    #  end
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

    def self.configure(&block)
      class_eval(&block)
    end

    def self.start(&block)
      define_method(:start, &block)
    end

    def self.finish(&block)
      define_method(:finish, &block)
    end

    #
    attr :specs

    #
    attr_accessor :format

    #
    attr_accessor :trace

    #attr :context
    #attr :count

    #attr_accessor :before
    #attr_accessor :after

    # New Specification
    def initialize(specs, options={})
      @specs       = [specs].flatten

      @format      = :dotprogress
      @trace       = false

      options.each do |k,v|
        __send__("#{k}=", v) if v
      end
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
      when :script #ditto ?
        # TODO
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
      start
      output.report_intro
      specs.each do |spec|   # loop through each specification and run it
        run_spec(spec)       # run the specification
      end
      output.report_summary
      finish
    end

    # Run a specification.
    def run_spec(spec)
      script = Script.new(spec, output)

      # pretty sure this is the thing to do
      Dir.chdir(File.dirname(spec)) do

        output.report_start(spec)

        # TODO <-- plugin in here start (how to set?)
        #context.instance_eval(&spec.given) if spec.given

        script.run

        #spec.steps.each do |step|
          #output.report_step(self)
          #step.run(self, spec, context, output)
          #output.report_step_end(self)
        #end

        # TODO <-- plugin in here end
        #context.instance_eval(&spec.complete) if spec.complete

        output.report_end(spec)
      end
    end

=begin
    # Run a specification step.
    #
    def run_step(spec, step)
      output.report_step(step)
      # TODO: Would spec.before + spec.code be better?
      context.instance_eval(@before, spec.file) if @before
      begin
        context.instance_eval(step.code, spec.file, step.lineno)
        output.report_pass(step)
      rescue Assertion => error
        output.report_fail(step, error)
      rescue Exception => error
        output.report_error(step, error)
      ensure
        context.instance_eval(@after, spec.file) if @after
      end
    end

    # Run a specification tabular step.
    #
    # TODO: Table reporting needs to be improved. Big time!
    def run_table(spec, step)
      table = YAML.load(File.new(step.file))  # yaml or csv ?

      vars = *table[0]
      rows = table[1..-1]

      output.report_step(step)
      context.instance_eval(@before, spec.file) if @before
      rows.each do |row|
        set  = vars.zip(row).map{ |a| "#{a[0]}=#{a[1].inspect}" }.join(';')
        code = set + "\n" + step.code
        begin
          context.instance_eval(code, spec.file, step.lineno)
          #output.report_literal(set)
          output.report_pass(step)
        rescue Assertion => error
          output.report_fail(step, error)
        rescue Exception => error
          output.report_error(step, error)
        ensure
          context.instance_eval(@after, spec.file) if @after
        end
      end
    end
=end

    def start
    end

    def finish
    end

  end#class Runner

end#module QED

