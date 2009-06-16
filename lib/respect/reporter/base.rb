module Respect
module Reporter

  require 'clio/facets/string'
  require 'clio/ansicode'

  # = Reporter BaseClass
  #
  # Serves as the base class for all other specification 
  # output formats.
  # 
  class BaseClass

    ANSICode = Clio::ANSICode

    attr :steps
    attr :pass
    attr :fail
    attr :error

    def initialize
      @specs = 0
      @steps = 0
      @pass  = []
      @fail  = []
      @error = []
    end

    # Before running any specifications.
    def report_intro
    end

    # Beginning of a specification.
    def report_start(spec)
      @specs += 1
    end

    # Report a header.
    def report_header(step)
    end

    # Report a comment.
    def report_comment(step)
    end

    # Er... what was this for?
    #def report_mode(step)
    #  report_literal(step)
    #end

    # Before running a step.
    def report_step(step)
      @steps += 1
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
    def report_macro(step)
    end

    # Report on omitted step.
    def report_omit(step)
    end

    # After running a step.
    def report_step_end(step)
    end

    # End of a specification.
    def report_end(spec)
    end

    # After running all specifications.
    def report_summary
    end

  end

end
end

