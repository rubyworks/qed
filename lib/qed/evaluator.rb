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
      advise!(:before_document, @script)
      process
      advise!(:after_document, @script)
    end

    #
    def process
      @ast.each do |section|
        case section.type
        when :code
          evaluate_code(section)
        when :text
          evaluate_text(section)
        end
      end
    end

    #
    def evaluate_code(section)
      advise!(:before_code, section, @script.file)
      begin
        advise!(:code, section)
        @script.evaluate(section.text, section.line)
        pass!(section)
      rescue Assertion => exception
        fail!(section, exception)
      rescue Exception => exception
        error!(section, exception)
      end
      advise!(:after_code, section, @script.file)
    end

    #
    def evaluate_text(section)
      advise!(:text, section)
      evaluate_links(section)
      advise!(:when, section)
    end

    #
    def evaluate_links(section)
      section.text.scan(/\[qed:\/\/(.*?)\]/) do |match|
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
          Script.new(@script.applique, file, @script.scope).run
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

