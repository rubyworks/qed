module QED

  require 'tilt'
  require 'nokogiri'
  require 'qed/scope'

  # = Demo Script Evaluator
  #
  #--
  # TODO: Currently the Evaluator class uses #traverse to work
  # thru the HTML document and trigger events accordingly. This
  # works well enough for simple HTML documents --the kind produced
  # by typical wiki-markup formats. However, for complex HTML it
  # it will not produce ideal output (although the code segements
  # should still run just fine). To counter this weakness, we will
  # may have to swtich to a more complex SAX parser in the future.
  #--
  class Evaluator

    #
    def initialize(script, *observers)
      @script  = script
      @file    = script.file
      @root    = script.root
      @scope   = script.scope
      @binding = script.binding
      @advice  = script.advice

      @observers = observers
    end

    #
    def run
      Dir.chdir(File.dirname(@file)) do
        advise!(:before_document, @script)
        #@root.traverse do |element|
        #  call_tag(element)
        #end
        #body = @root.at('body')
        #process(body)
        process(@root)
        advise!(:after_document, @script)
      end
    end

    #
    def process(node)
      node.children.each do |child|
        case child
        when Nokogiri::XML::Element
          call_tag(child)
        end
      end
    end

    #
    def call_tag(element)
      advise!(:tag, element)
      __send__("tag_#{element.name}", element)
    end

    # T A G S

    #
    def tag_body(element)
      process(element)
    end

    #
    def tag_a(element)
      case element['href']
      when /qed:\/\/(.*?)$/
        file = $1
        case File.extname(file)
        when '.rb'
          import!(file)
        else
          Script.new(file, @scope).run
        end
      end
    end

    #
    def tag_pre(element)
      advise!(:before_code, element, @file)
      begin
        eval(element.text, @binding, @file, element.line)
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
      # process links
      if hrefs = element.search('a')
        hrefs.each do |href|
          tag_a(href)
        end
      end
      if pre = element.at('.quote')
        text = clean_quote(pre.text)
        advise!(:when, element.text, text)
      else
        advise!(:when, element.text)
        if pres = element.search('pre')
          pres.each do |pre|
            tag_pre(pre)
          end
        end
      end    
    end

    #
    def clean_quote(text)
      text = text.unindent.chomp.sub(/\A\n/,'')
      if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
        text = md[1]
      end
      text
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
      eval(File.read(file), @binding, file)
      advise!(:load, file)
    end

    #
    def advise!(signal, *args)
      @observers.each{ |o| o.update(signal, *args) }
      #@scope.__advice__.call(signal, *args)
      @advice.call(signal, *args)
    end

    #
    #def advise_when!(match)
    #  @advice.call_when(match)
    #end

  end

end

