require 'qed/step'

module QED

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
    # @option options [Symbol] :mode
    #   Parse in `:comment` mode or default mode.
    #
    def initialize(demo, options={})
      @demo  = demo
      @mode  = options[:mode]
      @steps = []
    end

    # The demo to parse.
    attr :demo

    # Parser mode.
    attr :mode

    # Abstract Syntax Tree
    attr :steps

    # The demo's file to parse.
    def file
      demo.file
    end

    # Lines of demo, prepared for parsing into steps.
    def lines
      @lines ||= parse_lines
    end

    # Prepare lines for parsing into steps.
    def parse_lines
      case mode
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

    # Parse comment lines into a format that the parse method can use.
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

    # Parse demo file into steps.
    def parse
      steps    = []
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
            steps << Step.new(demo, explain, example, steps.last)
            explain, example = [], [] #Step.new(file)
          end
          indented = false
          blank    = false
          explain << [lineno, line]
        end
      end
      steps << Step.new(demo, explain, example, steps.last)
      @steps = steps
    end

  end

end
