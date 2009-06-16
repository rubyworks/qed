#require 'quarry/behave'
#require 'quarry/runner/context'

module Respect

  require 'respect/script'

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

    #  Quarry::Spec::Runner.configure do
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

    attr :specs
    attr :output

    #attr :context
    #attr :count

    #attr_accessor :before
    #attr_accessor :after

    # New Specification
    def initialize(specs, output=nil)
      @specs  = [specs].flatten
      @output = output || Reporter::DotProgress.new #(self)
    end

    #
    def check
      output.report_intro
      # loop through each specification and run it
      specs.each do |spec|
        # create a run context for the spec
        #@context = Context.new(spec)
        # run the specification
        run_spec(spec)
      end
      output.report_summary
    end

    # Run a specification.
    #
    def run_spec(spec)
      #report(spec.description)

      script = Script.load(spec, output)

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

  end#class Runner

end#module Quarry

