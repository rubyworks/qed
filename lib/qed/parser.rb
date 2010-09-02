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
        index = 0  #-1
        File.readlines(file).to_a.map do |line|
          [index += 1, line]
        end
      end
    end

    # TODO: It would be nice if we could get ther require statement for the 
    # comment mode to be relative to an actual loadpath.
    def parse_comment_lines
      ruby_omit = false
      rdoc_omit = false
      lines = [
        [0, "Load #{File.basename(file)} script.\n"],
        [0, "\n"],
        [0, "  require '#{file}'\n"]
      ]
      index = 1
      File.readlines(file).each do |l|
        case l
        when /^=begin(?!\s+qed)/
          ruby_omit = true
        when /^=end/
          ruby_omit = false
        when /^\s*\#\-\-\s*$/
          rdoc_omit = true
        when /^\s*\#\+\+\s*$/
          rdoc_omit = false
        ##when /^\s*\#\ \-\-/  # not needed just double comment
        ##  # -- skip internal comments
        when /^\s*##/
          ## skip internal comments
        when /^\s*\#/
          lines << [index, l.lstrip.sub(/^\#\ ?/, '')] unless (ruby_omit or rdoc_omit)
        else
          lines << [index, "\n"] unless lines.last[1] == "\n" unless (ruby_omit or rdoc_omit)
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
      flush = true
      pend  = false
      block = Block.new(file)
      lines.each do |lineno, line|
        case line
        when /^\s*$/
          if flush
            pend = true unless lineno == 0
            block.raw << [lineno, line]
          else
            block.raw << [lineno, line]
          end
        when /\A\s+/
          if flush
            tree << block.ready!(flush, tree.last)
            block = Block.new(file)         
          end
          pend  = false
          flush = false
          block.raw << [lineno, line]
        else
          if pend || !flush
            tree << block.ready!(flush, tree.last)
            pend  = false
            flush = true
            block = Block.new(file)
          end
          block.raw << [lineno, line]
        end
      end
      tree << block.ready!(flush, tree.last)
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
      # Block raw code/text.
      attr :raw

      # previous block
      attr :back_step

      # next block
      attr :next_step

      #
      def initialize(file)
        @file = file
        @raw  = []
        @type = :description
        @back_step = nil
        @next_step = nil
      end

      #
      def ready!(flush, back_step)
        @flush     = flush
        @back_step = back_step

        @text  = raw.map{ |lineno, line| line }.join
        @type  = parse_type

        @back_step.next_step = self if @back_step

        self
      end

      #
      def to_s
        case type
        when :description
          text
        else
          text
        end
      end

      #
      def text
        @text
      end

      #
      def flush?
        @flush
      end

      # Returns an Array of prepared example text
      # for use in advice.
      def arguments
        if next_step && next_step.data?
          [next_step.sample_text]
        else
          []
        end
      end

      # What type of block is this?
      def type
        @type
      end

      #
      def head? ; @type == :head ; end

      #
      def desc? ; @type == :desc ; end

      #
      def code? ; @type == :code ; end

      # Any commentary ending in `...` or `:` will mark the following
      # block as a plain text *sample* and not example code to be evaluated.
      def data? ; @type == :data ; end

      #
      alias_method :header?, :head?

      #
      alias_method :description?, :desc?


      # First line of example text.
      def lineno
        @line ||= @raw.first.first
      end

      #
      def code
        @code ||= tweak_code
      end

      # Clean up the example text, removing unccesseary white lines
      # and triple quote brackets, but keep indention intact.
      def clean_text
        str = text.chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(str)
          str = md[1]
        end
        str.rstrip
      end

      # When the text is sample text and passed to an adivce block, this
      # provides the prepared form of the example text, removing white lines,
      # triple quote brackets and indention.
      def sample_text
        str = text.tabto(0).chomp.sub(/\A\n/,'')
        if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(str)
          str = md[1]
        end
        str.rstrip
      end

      # TODO: object_hexid
      def inspect
        %[#<Block:#{object_id} "#{text[0..25]} ...">]
      end

    protected

      #
      def next_step=(n)
        @next_step = n
      end

    private

      #
      def parse_type
        if flush?
          if /\A[=#]/ =~ text
            :head
          else
            :desc
          end
        else
          if back_step && /(\.\.\.|\:)\s*\Z/m =~ back_step.text.strip
            :data
          else
            :code
          end
        end
      end

      #
      def tweak_code
        code = text.dup
        code.gsub!(/\n\s*\#\ ?\=\>/, '.assert = ')
        code.gsub!(/\s*\#\ ?\=\>/, '.assert = ')
        code
      end

    end

  end

end

