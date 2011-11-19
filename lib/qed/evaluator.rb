module QED

  require 'qed/scope'

  # Demonstrandum Evaluator is responsible for running demo scripts.
  #
  class Evaluator

    # Setup new evaluator instance.
    #
    def initialize(demo, *observers)
      @demo  = demo
      @steps = demo.steps

      @observers = observers + applique_observers
    end

    # Collect applique all the signal-based advice and wrap their evaluation
    # in observable procedure calls.
    #
    def applique_observers
      demo = @demo
      demo.applique.map do |a|
        Proc.new do |type, *args|
          proc = a.__signals__[type.to_sym] 
          demo.scope.instance_exec(*args, &proc) if proc
        end
      end
    end

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

    #
    def run_steps
      @steps.each do |step|
        evaluate(step)
      end
    end

    def evaluate(step)
      advise!(:before_step, step)
      advise!(:step, step)

      if step.assertive?
        evaluate_links(step) unless step.heading?
        evaluate_assertion(step)
      else
        evaluate_procedure(step)
      end

      advise!(:after_step, step)
    end

    # TODO: Not sure how to handle loading links in --comment runner mode.

    # TODO: Do not think Scope should be reuseud by imported demo.

    # If there are embedded links in the step description than extract
    # them and load them in.
    #
    def evaluate_links(step)
      step.text.scan(/\[qed:\/\/(.*?)\]/) do |match|
        file = $1
        # relative to demo demo
        if File.exist?(File.join(@demo.directory,file))
          file = File.join(@demo.directory,file)
        end
        # ruby or another demo
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Demo.new(file, :scope=>@demo.scope).run
        end
      end
    end

    #
    def evaluate_procedure(step)
      advise!(:before_proc, step)
      begin
        advise!(:proc, step)
        evaluate_matchers(step)
        evaluate_code(step)
      ensure
        advise!(:after_proc, step)
      end
    end

    #
    FORCED_EXCEPTIONS = [NoMemoryError, SignalException, Interrupt] #, SystemExit]

    #
    def evaluate_assertion(step)
      advise!(:before_eval, step)  # TODO: pass demo to advice?
      begin
        advise!(:eval, step)  # name ?
        evaluate_matchers(step)
        evaluate_code(step)
      rescue *FORCED_EXCEPTIONS
        raise
      rescue SystemExit
        pass!(step)
      #rescue Assertion => exception
      #  fail!(step, exception)
      rescue Exception => exception
        if exception.assertion?
          fail!(step, exception)
        else
          error!(step, exception)
        end
      else
        pass!(step)
      ensure
        advise!(:after_eval, step)
      end
    end

    #
    def evaluate_code(step)
      @demo.evaluate(step.code, step.lineno) if step.code?
    end

    #
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

            @demo.scope.instance_exec(*args, &proc)  #proc.call(*args)
          end
        end
      end
    end

    SPLIT_PATTERNS = [ /(\(\(.*?\)\)(?!\)))/, /(\/\(.*?\)\/)/, /(\/\?.*?\/)/ ]

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

    #
    def pass!(step)
      advise!(:pass, step)
    end

    #
    def fail!(step, exception)
      advise!(:fail, step, exception)
      #raise exception
    end

    #
    def error!(step, exception)
      advise!(:error, step, exception)
      #raise exception
    end

    #
    def import!(file)
      advise!(:before_import, file)
      Kernel.eval(File.read(file), @demo.binding, file)
      advise!(:after_import, file)
    end

    # Dispatch event to observers and advice.
    def advise!(signal, *args)
      @observers.each{ |o| o.call(signal.to_sym, *args) }
    end

  end

end
