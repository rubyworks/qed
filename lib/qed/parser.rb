require 'qed/step'

module QED

  # Globally accessable list of all steps.
  #
  # NOTE: Can't say I like having this, but it might be the only way to 
  # get a complete count of the number of total steps, no?
  #
  # DEPRECATE IF POSSIBLE!
  #def self.all_steps
  #  @all_steps ||= []
  #end

  # The parser breaks down a demonstandum into structured object
  # to passed thru the script evaluator.
  # 
  # Technically is defines it's own markup language but for
  # interoperability sake it is RDoc and/or Markdown.
  #
  class Parser

    # Setup new parser instance.
    #
    # @param [Demo] demo
    #   This demo, which is to be parsed.
    #
    # @param [Hash] options
    #   Parsing options.
    #
    # @option options [Symbol] mode
    #   Parse in `:comment` mode or default mode.
    #
    def initialize(demo, options={})
      @demo    = demo
      @options = options
      @ast     = []
    end

    # The demo to parse.
    attr :demo

    # Parser options.
    attr :options

    # Abstract Syntax Tree
    attr :ast

    # The demo's file to parse.
    def file
      demo.file
    end

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

    #
    def parse
      tree     = []
      blank    = false
      indented = false
      explain  = []
      example  = [] #Step.new(file)

      lines.each do |lineno, line|
        case line
        when /^\s*$/  # blank line
          blank = true
          if indented
            example << [lineno, line]
          else
            explain << [lineno, line]
          end
        when /\A\s+/  #/\A(\t|\ \ +)/  # indented
          indented = true
          blank    = false
          example << [lineno, line]
        else
          if indented or blank
            tree << Step.new(demo, explain, example, tree.last)
            explain, example = [], [] #Step.new(file)
          end
          indented = false
          blank    = false
          explain << [lineno, line]
        end
      end
      tree << Step.new(demo, explain, example, tree.last)
      @ast = tree
    end

=begin
    def parse
      tree  = []
      flush = true
      pend  = false
      block = Step.new(file)
      lines.each do |lineno, line|
        case line
        when /^\s*$/  # blank line
          if flush
            pend = true unless lineno == 0
            block.raw << [lineno, line]
          else
            block.raw << [lineno, line]
          end
        when /\A\s+/  #/\A(\t|\ \ +)/  # indented
          if flush
            tree << block.ready!(flush, tree.last)
            block = Step.new(file)         
          end
          pend  = false
          flush = false
          block.raw << [lineno, line]
        else # new paragraph
          if pend || !flush
            tree << block.ready!(flush, tree.last)
            pend  = false
            flush = true
            block = Step.new(file)
          end
          block.raw << [lineno, line]
        end
      end
      tree << block.ready!(flush, tree.last)
      @ast = tree
    end
=end

    # TODO: We need to preserve the indentation for the verbatim reporter.
    #def clean_quote(text)
    #  text = text.tabto(0).chomp.sub(/\A\n/,'')
    #  if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
    #    text = md[1]
    #  end
    #  text.rstrip
    #end

  end

end

