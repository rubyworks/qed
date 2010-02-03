module QED

  require 'tilt'
  require 'nokogiri'
  require 'qed/scope'

  # = Demo Script Evaluator
  #
  #--
  # TODO: Currently the Evaluator class uses #travserse to work
  # thru the HTML document and trigger events accordingly. This
  # works well enough for simple HTML documents --the kind produced
  # by typical wiki-markup formats. However, for complex HTML it
  # it will not produce ideal output (although the code segements
  # should still run just fine). To counter this weakness, we will
  # have to swtich to a more complex SAX parser in the future.
  #--
  class Evaluator

    #
    def initialize(script, *observers)
      @file  = script.file
      @scope = script.scope
      @root  = script.root

      @observers = observers
    end

    #
    def run
      Dir.chdir(File.dirname(@file)) do
        advise!(:before_document, self)
        @root.traverse do |element|
          call_tag(element)
        end
        advise!(:after_document, self)
      end
    end

    #
    def call_tag(element)
      advise!(:tag, element)
      __send__("tag_#{element.name}", element)
    end

    # T A G S

    #
    def tag_a(element)
      case element['href']
      when /qed:\/\/(.*?)$/
        file = $1
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Script.new(file, scope).run
        end
      end
    end

    #
    def tag_pre(element)
      advise!(:before_code, element, @file)
      begin
        eval(element.text, @scope.__binding__, @file, element.line)
        pass!(element)
      rescue Assertion => exception
        fail!(element, exception)
      rescue Exception => exception
        error!(element, exception)
      end
      advise!(:after_code, element, @file)
    end

    #
    def tag_p(element)
      advise!(:when, element.text)
    end

    #
    def method_missing(s, *a)
      super(s, *a) unless /^tag/ =~ s.to_s
    end

    #
    def pass!(element)
      advise!(:pass, element)
    end

    #
    def fail!(element, exception)
      advise!(:fail, element, exception)
      #raise exception
    end

    #
    def error!(element, exception)
      advise!(:error, element, exception)
      #raise exception
    end

    #
    def import!(file)
      advise!(:unload)
      eval(File.read(file), @scope.__binding__, file)
      advise!(:load, file)
    end

    #
    def advise!(signal, *args)
      @observers.each{ |o| o.update(signal, *args) }
      @scope.__advice__.call(signal, *args)
    end

    #
    #def advise_when!(match)
    #  @scope.__advice__.call_when(match)
    #end

  end

end
