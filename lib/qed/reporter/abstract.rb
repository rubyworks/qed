module QED
module Reporter

  require 'facets/string'
  require 'ansi/code'

  # = Reporter Absract Base Class
  #
  # Serves as the base class for all other output formats.
  #
  class Abstract

    attr :io
    attr :steps
    attr :omit

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

    def passes   ; @pass  ; end
    def errors   ; @error ; end
    def failures ; @fail  ; end

    #
    def trace?
      @trace
    end

    #
    def update(type, *args)
      __send__("#{type}", *args)
    end


    def self.When(type, &block)
      #raise ArgumentError unless %w{session demo demonstration step}.include?(type.to_s)
      #type = :demonstration if type.to_s == 'demo'
      define_method(type, &block)
    end

    def self.Before(type, &block)
    #  raise ArgumentError unless %w{session demo demonstration step}.include?(type.to_s)
    #  type = :demonstration if type.to_s == 'demo'
      define_method("before_#{type}", &block)
    end

    def self.After(type, &block)
    #  raise ArgumentError unless %w{session demo demonstration step pass fail error}.include?(type.to_s)
    #  type = :demonstration if type.to_s == 'demo'
      define_method("after_#{type}", &block)
    end

    #
    #def Before(type, target, *args)
    #  type = :demonstration if type.to_s == 'demo'
    #  __send__("before_#{type}", target, *args)
    #end

    #
    #def After(type, target, *args)
    #  type = :demonstration if type.to_s == 'demo'
    #  __send__("after_#{type}", target, *args)
    #end

    # At the start of a session, before running any demonstrations.
    def before_session(session)
    end

    # Beginning of a demonstration.
    def before_demo(demo) #demo(demo)
      @demos += 1
    end

    #
    def load(demo)
    end

    #
    def import(file)
    end

    #def comment(elem)
    #end

    # Before running a step that is omitted.
    #def omit_step(step)
    #  @omit << step
    #end

    #
    def before_step(step)
      #@steps += 1
    end

    #
    def before_head(step)
    end

    #
    def before_desc(step)
    end

    #
    def before_code(step)
      @steps += 1
    end

    #
    def before_data(step)
    end

    #
    def head(step)
    end

    # Right before running code.
    def code(step)
    end

    # Right before text section.
    def desc(step)  #text ?
    end

    #
    def data(step)
    end

    # After running a step that passed.
    def pass(step)
      @pass << step
    end

    # After running a step that failed.
    def fail(step, assertion)
      @fail << [step, assertion]
    end

    # After running a step that raised an error.
    def error(step, exception)
      raise exception if $DEBUG
      @error << [step, exception]
    end

    #
    def after_data(step)
    end

    #
    def after_code(step)
    end

    #
    def after_desc(step)
    end

    #
    def after_head(step)
    end

    #
    def after_step(step)
    end

    #
    def unload
    end

    # End of a demonstration.
    def after_demo(demo)  #demo(demo)
    end

    # After running all demonstrations. This is the place
    # to output a summary of the session, if applicable.
    def after_session(session)
    end

    #
    def when(*args)
    end

  private

    #
    def clean_backtrace(btrace)
      btrace.chomp(":in \`__binding__'")
    end

  end

end
end

