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
      add_section(state, text, linein)
      @ast.reject!{ |sect| sect.type == :code && sect.text.strip.empty? }
      return @ast
    end

    #
    def add_section(state, text, lineno)
      case state
      when :code
        if ast.last.raw?
          @ast.last << text #clean_quote(text)
        else
          @ast << CodeSection.new(text, lineno)
        end
      else
        @ast << TextSection.new(text, lineno)
        #cont = (/\.\.\.\s*^/ =~ text ? true : false)
      end
    end

    # TODO: We need to preserve the indentation for the verbatim reporter.
    #def clean_quote(text)
    #  text = text.tabto(0).chomp.sub(/\A\n/,'')
    #  if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
    #    text = md[1]
    #  end
    #  text.rstrip
    #end

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
      attr :cont
      def initialize(text, line, *args)
        @text = text
        @line = line
        @args = args
        @cont = []
      end
      def <<(text)
        @cont << clean_continuation(text)
        @args << block_continuation(text)
      end
      def type
        :text
      end
      # TODO: Use ':' or '...' ?
      def raw?
        #/\:\s*\Z/m =~ text
        /\.\.\.\s*\Z/m =~ text
      end

      # Clean up the text, removing unccesseary white lines and triple
      # quote brackets, but keep indention intact.
      def clean_continuation(text)
        text = text.chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
          text = md[1]
        end
        text.rstrip
      end

      # Block the text, removing white lines, triple quote brackets
      # and indention.
      def block_continuation(text)
        text = text.tabto(0).chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
          text = md[1]
        end
        text.rstrip
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

