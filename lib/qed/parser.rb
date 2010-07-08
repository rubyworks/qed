module QED

  # The parser breaks down a demonstandum into
  # structured object to passed thru the script
  # evaluator.
  # 
  # Technically is defines it's own markup language
  # but for interoperability sake it is RDoc and a bit of
  # support for Markdown.
  class Parser

    #
    def initialize(file, options={})
      @file    = file
      @options = options
      @ast     = []
    end

    # Abstract Syntax Tree
    attr :ast

    # File to parse.
    attr :file

    # Parser options.
    attr :options

    #
    def lines
      @lines ||= (
        case options[:mode].to_sym
        when :comment
          ls = ["Load #{File.basename(file)} script.\n", "\n", "  require '#{file}'\n"]
          File.readlines(file).each do |l|
            if /^\s*\#/ =~ l
              ls << l.lstrip.sub(/^\#\ ?/, '')
            else
              ls << "\n" unless ls.last == "\n"
            end
          end
        else
          ls = File.readlines(file).to_a
        end
        ls
      )
    end

    # Parse the demo into an abstract syntax tree.
    #
    # TODO: I know there has to be a faster way to do this.
    def parse
      blocks = [[]]
      state  = :none
      lines.each_with_index do |line, lineno|
        case line
        when /^$/
          case state 
          when :code
            blocks.last << line
          when :blank
            blocks.last << line
          else
            blocks.last << line
            state = :blank
          end
        when /^\s+/
          blocks << [] if state != :code
          blocks.last << line
          state = :code
        else
          blocks << [] if state != :text
          blocks.last << line
          state = :text
        end
      end
      blocks.shift if blocks.first.empty?

      line_cnt = 1
      blocks.each do |block|
        text = block.join
        case text
        when /\A\s+/
          add_section(:code, text, line_cnt)
        else
          add_section(:text, text, line_cnt)          
        end
        line_cnt += block.size
      end
      #@ast.reject!{ |sect| sect.type == :code && sect.text.strip.empty? }
      return @ast
    end

    #
    def add_section(state, text, lineno)
      case state
      when :code
        if ast.last && ast.last.cont?
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

      #
      def <<(text)
        @cont << clean_continuation(text)
        @args << block_continuation(text)
      end

      #
      def type
        :text
      end

      # TODO: Use ':' or '...' ?
      def cont?
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
      attr :code
      def initialize(text, line) #, *args)
        @text = text
        @line = line
        #@args = args
        @code = parse(text)
      end
      #def <<(arg)
      #  @args << arg
      #end
      def type
        :code
      end
      #
      def parse(text)
        code = @text.dup
        code.gsub!(/\n\s*\#\=\>/, '.assert == ')
        code.gsub!(/\s*\#\=\>/, '.assert == ')
        code
      end
    end

  end

end

