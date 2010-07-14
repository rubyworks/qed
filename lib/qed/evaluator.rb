module QED

  require 'qed/scope'

  # = Demonstrandum Evaluator
  class Evaluator

    #
    def initialize(script, *observers)
      @script  = script
      @ast     = script.parse

      #@file    = script.file
      #@scope   = script.scope
      #@binding = script.binding
      #@advice  = script.advice

      @observers = observers
    end

    #
    def run
      advise!(:before_demo, @script)
      process
      advise!(:after_demo, @script)
    end

    #
    def process
      @ast.each do |section|
        evaluate(section)
      end
    end

    # Evaluate a demo section.
    def evaluate(section)
      advise!(:text, section) # TODO: rename to :step?
      evaluate_links(section)
      advise!(:before_step, section, @script.file)
      begin
        advise!(:when, section)
        # TODO: how to handle catching asserts in advice?
      end
      if section.code?
        begin
          advise!(:code, section)
          @script.evaluate(section.eval_code, section.lineno)
        rescue SystemExit
          pass!(section)
        rescue Assertion => exception
          fail!(section, exception)
        rescue Exception => exception
          error!(section, exception)
        else
          pass!(section)
        end
      end
      advise!(:after_step, section, @script.file)
    end

    # TODO: Not sure how to handle loading links in comment mode.
    def evaluate_links(section)
      section.commentary.scan(/\[qed:\/\/(.*?)\]/) do |match|
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
    def pass!(section)
      advise!(:pass, section)
    end

    #
    def fail!(section, exception)
      advise!(:fail, section, exception)
      #raise exception
    end

    #
    def error!(section, exception)
      advise!(:error, section, exception)
      #raise exception
    end

    #
    def import!(file)
      advise!(:unload)
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

