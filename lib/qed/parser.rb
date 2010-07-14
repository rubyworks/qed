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
      @lines ||= parse_lines
    end

    #
    def parse_lines
      case options[:mode]
      when :comment
        parse_comment_lines
      else
        index = -1
        File.readlines(file).to_a.map do |line|
          [index += 1, line]
        end
      end
    end

    # TODO: It would be nice if we could get ther require statement for the 
    # comment mode to be relative to an actual loadpath.
    def parse_comment_lines
      omit = false
      lines = [
        [0, "Load #{File.basename(file)} script.\n"],
        [0, "\n"],
        [0, "  require '#{file}'\n"]
      ]
      index = 0
      File.readlines(file).each do |l|
        case l
        when /^\s*\#\-\-\s*$/
          omit = true
        when /^\s*\#\+\+\s*$/
          omit = false
        when /^\s*\#\ \-\-/  # ?
          # -- skip internal comments
        when /^\s*\#/    
          lines << [index, l.lstrip.sub(/^\#\ ?/, '')] unless omit
        else
          lines << [index, "\n"] unless lines.last[1] == "\n"
        end
        index += 1
      end
      lines
    end

=begin
    # Parse the demo into an abstract syntax tree.
    #
    # TODO: I know there has to be a faster way to do this.
    def parse
      blocks = [[]]
      state  = :none
      lines.each do |lineno, line|
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
=end

    def parse
      tree  = []
      mode  = :rem
      pend  = false
      block = Block.new
      lines.each do |lineno, line|
        case line
        when /^\s*$/
          case mode
          when :rem
            pend = true unless line == 0
            block.rem << [lineno, line]
          when :raw
            block.raw << [lineno, line]
          end
        when /\A\s+/
          mode = :raw
          block.raw << [lineno, line]
        else
          if pend || mode == :raw
            pend = false
            mode = :rem
            tree << block.ready!
            block = Block.new
          end
          block.rem << [lineno, line]
        end
      end
      tree << block.ready!
      @ast = tree
    end

    # TODO: We need to preserve the indentation for the verbatim reporter.
    #def clean_quote(text)
    #  text = text.tabto(0).chomp.sub(/\A\n/,'')
    #  if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
    #    text = md[1]
    #  end
    #  text.rstrip
    #end

    # Section Block
    class Block
      # Block commentary.
      attr :rem

      # Block raw code/text.
      attr :raw

      #
      def initialize
        @rem = []
        @raw = []
        @has_code = true
      end

      #
      def ready!
        @commentary = rem.map{ |lineno, line| line }.join
        @example    = raw.map{ |lineno, line| line }.join
        @has_code   = false if @raw.empty?
        @has_code   = false if continuation?
        self
      end

      #
      def commentary
        @commentary
      end

      #
      def example
        @example
      end

      # Returns an Array of prepared example text
      # for use in advice.
      def arguments
        continuation? ? [example_argument] : []
      end

      #
      def code?
        @has_code
      end

      # First line of example text.
      def lineno
        @line ||= @raw.first.first
      end

      #
      def code
        @example
      end

      #
      def eval_code
        @eval_code ||= tweak_code
      end

      #
      def tweak_code
        code = example.dup
        code.gsub!(/\n\s*\#\ ?\=\>/, '.assert == ')
        code.gsub!(/\s*\#\ ?\=\>/, '.assert == ')
        code
      end

      # Clean up the example text, removing unccesseary white lines
      # and triple quote brackets, but keep indention intact.
      def clean_example
        text = example.chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
          text = md[1]
        end
        text.rstrip
      end

      # When the example is raw text and passed to an adivce block, this
      # provides the prepared form of the example text, removing white lines,
      # triple quote brackets and indention.
      def example_argument
        text = example.tabto(0).chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
          text = md[1]
        end
        text.rstrip
      end

      # And commentary ending in `...` or `:` will mark the following
      # example as plain text and not code to be evaluated.
      def continuation?
        /(\.\.\.|\:)\s*\Z/m =~ commentary
      end

    end

  end

end

