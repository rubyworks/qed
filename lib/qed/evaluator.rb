module QED

  require 'qed/scope'

  # = Demonstrandum Evaluator
  class Evaluator

    #
    def initialize(script, *observers)
      @script  = script
      @steps   = script.parse

      #@file    = script.file
      #@scope   = script.scope
      #@binding = script.binding
      #@advice  = script.advice

      @observers = observers
    end

    #
    def run
      advise!(:before_demo, @script)
      run_steps
      advise!(:after_demo, @script)
    end

    #
    def run_steps #process
      @steps.each do |step|
        evaluate(step)
      end
    end

    #
    def evaluate(step)
      type = step.type
      advise!(:before_step, step) #, @script.file)
      advise!("before_#{type}".to_sym, step) #, @script.file)
      case type
      when :head
        evaluate_head(step)
      when :desc
        evaluate_desc(step)
      when :data
        evaluate_data(step)
      when :code
        evaluate_code(step)
      else
        raise "fatal: unknown #{type}"
      end
      advise!("after_#{type}".to_sym, step) #, @script.file)
      advise!(:after_step, step) #, @script.file)
    end

    #
    def evaluate_head(step)
      advise!(:head, step)
    end

    #
    def evaluate_desc(step)
      evaluate_links(step)
      begin
        advise!(:desc, step)
        advise!(:when, step) # triggers matchers
      rescue SystemExit
        pass!(step)
      rescue Assertion => exception
        fail!(step, exception)
      rescue Exception => exception
        error!(step, exception)
      else
        pass!(step)
      end
    end

    #
    def evaluate_data(step)
      advise!(:data, step)
    end

    # Evaluate a demo step.
    def evaluate_code(step)
      begin
        advise!(:code, step)
        @script.evaluate(step.code, step.lineno)
      rescue SystemExit
        pass!(step)
      rescue Assertion => exception
        fail!(step, exception)
      rescue Exception => exception
        error!(step, exception)
      else
        pass!(step)
      end
    end

    # TODO: Not sure how to handle loading links in --comment runner mode.
    def evaluate_links(step)
      step.text.scan(/\[qed:\/\/(.*?)\]/) do |match|
        file = $1
        # relative to demo script
        if File.exist?(File.join(@script.directory,file))
          file = File.join(@script.directory,file)
        end
        # ruby or another demo
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Demo.new(file, @script.applique, :scope=>@script.scope).run
        end
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
      advise!(:unload) # should this also occur just befor after_demo ?
      eval(File.read(file), @script.binding, file)
      advise!(:load, file)
    end

    # Dispatch event to observers and advice.
    def advise!(signal, *args)
      @observers.each{ |o| o.update(signal, *args) }
      @script.advise(signal, *args)
    end

    #
    #def advise_when!(match)
    #  @advice.call_when(match)
    #end

    ##
    #def method_missing(s, *a)
    #  super(s, *a) unless /^tag/ =~ s.to_s
    #end

  end

end

