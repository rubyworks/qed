module QED

  require 'qed/scope'

  # Demonstrandum Evaluator is responsible for running demo scripts.
  #
  class Evaluator

    # Create new Evaluator instance and then run it.
    def self.run(demo, options={})
      new(demo, options).run
    end

    # Setup new evaluator instance.
    #
    # @param [Demo] demo
    #   The demo to run.
    #
    # @option options [Boolean] :applique
    #   Is this applique code?
    #
    # @option options [Array] :observers
    #   Objects that respond to observable interface.
    #   Typically this is just a Reporter instance.
    #
    def initialize(demo, options={})
      @demo  = demo
      @steps = demo.steps

      #@settings  = options[:settings]
      @applique  = options[:applique]  # BOOLEAN FLAG

      @observers = options[:observers].to_a
      @observers += applique_observers

      @scope     = options[:scope] || Scope.new(demo)
    end

    # Collect applique all the signal-based advice and wrap their evaluation
    # in observable procedure calls.
    #
    def applique_observers
      demo = @demo
      demo.applique.map do |a|
        Proc.new do |type, *args|
          proc = a.__signals__[type.to_sym] 
          @scope.instance_exec(*args, &proc) if proc
        end
      end
    end

  public

    # The Demo being evaluated.
    #
    # @return [Demo]
    attr :demo

    # The observers.
    #
    attr :observers

    # Run the demo.
    #
    def run
      advise!(:before_demo, @demo)
      begin
        advise!(:demo, @demo)
        run_steps
      ensure
        advise!(:after_demo, @demo)
      end
    end

  private

    # Interate over each step and evaluate it.
    #
    def run_steps
      @steps.each do |step|
        evaluate(step)
      end
    end
   
    # Evaluate a step.
    #
    # @macro [new] step
    #
    # @param [Step] step
    #   The step being evaluated.
    #
    # @return nothing
    def evaluate(step)
      advise!(:before_step, step)
      advise!(:step, step)

      evaluate_links(step) unless step.heading?

      if step.assertive? && !@applique
        evaluate_test(step)
      else
        evaluate_applique(step)
      end

      advise!(:after_step, step)
    end

    # TODO: We may deprecate link helpers --it's probably not a good idea
    #       to have per-demo rules any way.

    # TODO: Not sure how to handle loading links in --comment runner mode.

    # TODO: Should scope be reused by imported demo ?

    # If there are embedded links in the step description than extract
    # them and load them in.
    #
    # @macro step
    def evaluate_links(step)
      step.text.scan(/(?:\(|\[)qed:\/\/(.*?)(?:\)|\])/) do |match|
        file = $1
        # relative to demo demo
        if File.exist?(File.join(@demo.directory,file))
          file = File.join(@demo.directory,file)
        end

        advise!(:before_import, file)
        begin
          advise!(:import, file)
          case File.extname(file)
          when '.rb'
            Kernel.eval(File.read(file), @scope.__binding__, file)
          else
            demo = Demo.new(file)
            Evaluator.new(demo, :scope=>@scope).run
          end
        ensure
          advise!(:after_import, file)
        end
      end
    end

    # Evaluate step at the *applique level*. This means the execution
    # of code and even matcher evaluations will not be captured by a
    # rescue clause.
    #
    # @macro step
    def evaluate_applique(step)
      advise!(:before_applique, step)
      begin
        advise!(:applique, step)
        evaluate_matchers(step)
        evaluate_example(step)
      ensure
        advise!(:after_applique, step)
      end
    end

    # Exceptions to always raise regardless.
    FORCED_EXCEPTIONS = [NoMemoryError, SignalException, Interrupt] #, SystemExit]

    # Evaluate the step's matchaters and code sample, wrapped in a begin-rescue
    # clause.
    #
    # @macro step
    def evaluate_test(step)
      advise!(:before_test, step)
      begin
        advise!(:test, step)  # name ?
        evaluate_matchers(step)
        evaluate_example(step)
      rescue *FORCED_EXCEPTIONS
        raise
      rescue SystemExit  # TODO: why pass on SystemExit ?
        advise!(:pass, step)
      #rescue Assertion => exception
      #  advise!(:fail, step, exception)
      rescue Exception => exception
        if exception.assertion?
          advise!(:fail, step, exception)
        else
          advise!(:error, step, exception)
        end
      else
        advise!(:pass, step)
      ensure
        advise!(:after_test, step)
      end
    end

    # Evaluate the step's example  in the demo's context, if the example
    # is source code.
    #
    # @macro step
    def evaluate_example(step)
      @scope.evaluate(step.code, step.file, step.lineno) if step.code?
    end

    # Search the step's description for applique matches and
    # evaluate them.
    #
    # @macro step
    def evaluate_matchers(step)
      match = step.text

      @demo.applique.each do |app|
        app.__matchers__.each do |(patterns, proc)|
          compare = match
          matched = true
          params  = []
          patterns.each do |pattern|
            case pattern
            when Regexp
              regex = pattern
            else
              regex = match_string_to_regexp(pattern)
            end
            if md = regex.match(compare)
              advise!(:match, step, md)     # ADVISE !
              params.concat(md[1..-1])
              compare = md.post_match
            else
              matched = false
              break
            end
          end
          if matched
            #args = [params, arguments].reject{|e| e == []}  # use single argument for params in 3.0?
            args = params
            args = args + [step.sample_text] if step.data?
            args = proc.arity < 0 ? args : args[0,proc.arity]

            #@demo.scope
            @scope.instance_exec(*args, &proc)  #proc.call(*args)
          end
        end
      end
    end

    #
    SPLIT_PATTERNS = [ /(\(\(.*?\)\)(?!\)))/, /(\/\(.*?\)\/)/, /(\/\?.*?\/)/ ]

    #
    SPLIT_PATTERN  = Regexp.new(SPLIT_PATTERNS.join('|'))

    # Convert matching string into a regular expression. If the string
    # contains double parenthesis, such as ((.*?)), then the text within
    # them is treated as in regular expression and kept verbatium.
    #
    def match_string_to_regexp(str)
      re = nil
      str = str.split(SPLIT_PATTERN).map do |x|
        case x
        when /\A\(\((.*?)\)\)(?!\))/
          $1
        when /\A\/(\(.*?\))\//
          $1
        when /\A\/(\?.*?)\//
          "(#{$1})"
        else
          Regexp.escape(x)
        end
      end.join

      str = str.gsub(/\\\s+/, '\s+')  # Replace space with variable space.

      Regexp.new(str, Regexp::IGNORECASE)
    end

=begin
    # The following code works as well, and can provide a MatchData
    # object instead of just matching params, but I call YAGNI on that
    # and it has two benefits. 1) the above code is faster, and 2)
    # using params allows |(name1, name2)| in rule blocks.

    #
    def evaluate_matchers(step)
      match = step.text
      args  = step.arguments
      @demo.applique.each do |a|
        matchers = a.__matchers__
        matchers.each do |(patterns, proc)|
          re = build_matcher_regexp(*patterns)
          if md = re.match(match)
            #params = [step.text.strip] + params
            #proc.call(*params)
            @demo.scope.instance_exec(md, *args, &proc)
          end
        end
      end
    end

    #
    def build_matcher_regexp(*patterns)
      parts = []
      patterns.each do |pattern|
        case pattern
        when Regexp
          parts << pattern
        else
          parts << match_string_to_regexp(pattern)
        end
      end
      Regexp.new(parts.join('.*?'), Regexp::MULTILINE)
    end
=end

    # TODO: pass demo to advice?

    # Dispatch an advice event to observers.
    #
    # @param [Symbol] signal
    #   The name of the dispatch.
    #
    # @param [Array<Object>] args
    #   Any arguments to send along witht =the signal to the observers.
    #
    # @return nothing
    def advise!(signal, *args)
      @observers.each{ |o| o.call(signal.to_sym, *args) }
    end

  end

end
