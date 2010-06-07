module QED

  # The parser breaks down a demonstandum into
  # structured object to passed thru the script
  # evaluator.
  # 
  # Technically is defines it's own markup language
  # but for interoperability sake it ...
  class Parser

    #
    def initialize(file)
      @lines = File.readlines(file).to_a
      @ast = []
    end

    #
    attr :ast

    #
    def parse
      state = :text
      linein = 0

      text  = ''

      @lines.each_with_index do |line, lineno|
        if /^\S/ =~ line
          if state == :code
            add_section(:code, text, linein)
            linein = lineno
            text = ''
          end
          state = :text
          text << line          
        else
          if state == :text
            next if text.strip.empty?
            add_section(:text, text, linein)
            linein = lineno
            text = ''
          end
          state = :code
          text << line          
        end
      end
      @ast.reject!{ |sect| sect.type == :code && sect.text.strip.empty? }
      return @ast
    end

    #
    def add_section(state, text, lineno)
      cont = nil
      case state
      when :code
        if cont
          @ast.last << clean_quote(text)
        else
          @ast << CodeSection.new(text, lineno)
        end
      else
        @ast << TextSection.new(text, lineno)
        cont = (/\.\.\.\s*^/ =~ text ? true : false)
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
    class Section
      attr :text
      attr :line
      def initialize(text, line)
        @text = text
        @line = line
      end
    end

    #
    class TextSection < Section
      attr :args
      def initialize(text, line, *args)
        @text = text
        @line = line
        @args = args
      end
      def <<(text)
        @args << text
      end
      def type
        :text
      end
    end

    #
    class CodeSection < Section
      #attr :args
      def intialize(text, line) #, *args)
        @text = text
        @line = line
        #@args = args
      end
      #def <<(arg)
      #  @args << arg
      #end
      def type
        :code
      end
    end

  end

end

