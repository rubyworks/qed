module QED

  require 'tilt'
  require 'nokogiri'
  require 'qed/scope'

  # = Demonstrandum Evaluator
  #--
  # TODO: Consider a more SAX parser for future versions.
  #--
  class Evaluator

    #
    def initialize(script, *observers)
      @script  = script
      @file    = script.file
      @ast     = script.parse
      @scope   = script.scope
      @binding = script.binding
      @advice  = script.advice

      @observers = observers
    end

    #
    def run
      Dir.chdir(File.dirname(@file)) do
        advise!(:before_document, @script)
        process
        advise!(:after_document, @script)
      end
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
      advise!(:before_code, section, @file)
      begin
        advise!(:code, section)
        eval(section.text, @binding, @file, section.line)
        pass!(section)
      rescue Assertion => exception
        fail!(section, exception)
      rescue Exception => exception
        error!(section, exception)
      end
      advise!(:after_code, section, @file)
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
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Script.new(@script.applique, @script.file, @script.scope).run
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
      eval(File.read(file), @binding, file)
      advise!(:load, file)
    end

    #
    def advise!(signal, *args)
      @observers.each{ |o| o.update(signal, *args) }
      #@scope.__advice__.call(signal, *args)
      @advice.call(@scope, signal, *args)
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

