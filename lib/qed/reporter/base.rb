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
    attr :omit
    attr :pass
    attr :fail
    attr :error

    def initialize(options={})
      @io    = options[:io] || STDOUT
      @trace = options[:trace]

      @demos = 0
      @steps = 0
      @omit  = []
      @pass  = []
      @fail  = []
      @error = []
    end

    #
    def trace?
      @trace
    end

    #
    def Before(type, target)
      case type
      when :session
        before_session(target)
      when :demo, :demonstration
        before_demonstration(target)
      when :step
        before_step(target)
      end
    end

    #
    def After(type, target)
      case type
      when :session
        after_session(target)
      when :demo, :demonstration
        after_demonstration(target)
      when :step
        after_step(target)
      end
    end

    # At the start of a session, before running any demonstrations.
    def before_session(session)
    end

    # Beginning of a demonstration.
    def before_demonstration(demo)
      @demos += 1
    end

    # Before running a step.
    def before_step(step)
      @steps += 1 if step.name == 'pre'
    end

    # Before running a step that is omitted.
    def omit_step(step)
      @omit << step
    end

    # After running a step that passed.
    def step_pass(step)
      @pass << step
    end

    # After running a step that failed.
    def step_fail(step, assertion)
      @fail << [step, assertion]
    end

    # After running a step that raised an error.
    def step_error(step, exception)
      raise exception if $DEBUG
      @error << [step, exception]
    end

    # After running a step.
    def after_step(step)
    end

    # End of a demonstration.
    def after_demonstration(demo)
    end

    # After running all demonstrations. This is the place
    # to output a summary of the session, if applicable.
    def after_session(session)
    end

  private

    #
    def clean_backtrace(btrace)
      btrace.chomp(":in \`_binding'")
    end

  end

end
end

