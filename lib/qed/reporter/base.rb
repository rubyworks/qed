module QED
module Reporter

  require 'facets/string'
  require 'ansi/code'

  # = Reporter BaseClass
  #
  # Serves as the base class for all other output formats.
  #
  class BaseClass

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
    def before_document(demo) #demo(demo)
      @demos += 1
    end

    #
    def tag(element)
    end

    #
    def load(demo)
    end
    #
    def import(file)
    end

    # Before running a step.
    def element(step)
    end

    def comment(elem)
    end

    # Before running a step that is omitted.
    #def omit_step(step)
    #  @omit << step
    #end

    #
    def before_code(step, file)
      @steps += 1
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
    def after_code(step, file)
    end

    #
    def after_element(elem)
    end

    #
    def unload
    end

    # End of a demonstration.
    def after_document(demo)  #demo(demo)
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

