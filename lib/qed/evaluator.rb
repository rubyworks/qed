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
      advise!(:demo, @demo)
      run_steps
      advise!(:after_demo, @demo)
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
      type = step.type

      advise!("before_#{type}", step)
      advise!(type, step)

      step.evaluate(@demo)

      advise!("after_#{type}", step)
    end

    #
    def evaluate_assertion(step)
      type = step.type

      begin
        advise!("before_#{type}", step) #, @demo.file)
        advise!(type, step)  # name ?

        step.evaluate(@demo)
  
        advise!("after_#{type}", step) #, @demo.file)
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
      end
    end

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
