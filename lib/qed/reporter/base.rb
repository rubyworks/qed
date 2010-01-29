module QED
module Reporter

  require 'facets/string'
  require 'ansi/code'

  # = Reporter BaseClass
  #
  # Serves as the base class for all other specification
  # output formats.
  #
  class BaseClass

    ANSICode = ANSI::Code

    attr :io
    attr :steps
    attr :pass
    attr :fail
    attr :error

    def initialize(options={})
      @io      = options[:io] || STDOUT
      @verbose = options[:verbose]

      @demos = 0
      @steps = 0
      @pass  = []
      @fail  = []
      @error = []
    end

    #
    def verbose?
      @verbose
    end

    # Before running any demonstration.
    def report_intro
    end

    # Beginning of a demonstration.
    def report_start(demo)
      @demos += 1
    end

    # Report a header.
    #def report_header(step)
    #end

    # Report a comment.
    #def report_comment(step)
    #end

    # Er... what was this for?
    #def report_mode(step)
    #  report_literal(step)
    #end

    # Report documentation part.
    #def report_doc(step)
    #end

    # Report on omitted step.
    def report_omit(step)
    end

    # Before running a step.
    def report_step(step)
      @steps += 1 if step.name == 'pre'
    end

    # Report step passed.
    def report_pass(step)
      @pass << step
    end

    # Report step failed.
    def report_fail(step, assertion)
      @fail << [step, assertion]
    end

    # Report step raised an error.
    def report_error(step, exception)
      raise exception if $DEBUG
      @error << [step, exception]
    end

    # Since regular macro step does not pass or fail,
    # this method is used instead.
    #
    # TODO: Rename to #report_nominal (?)
    #def report_macro(step)
    #end

    # After running a step.
    #def report_step_end(step)
    #end

    # End of a demonstration.
    def report_end(demo)
    end

    # After running all demonstrations.
    def report_summary
    end

  private

    #
    def clean_backtrace(btrace)
      btrace.chomp(":in `_binding'")
    end

  end

end
end

