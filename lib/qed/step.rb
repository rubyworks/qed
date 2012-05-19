module QED

  # A Step consists of a flush region of text and the indented 
  # text the follows it. QED breaks all demos down into step
  # for evaluation.
  #
  # Steps form a doubly linkes list, each having access to the step
  # before and the step after them. Potentially this could be used
  # by very advnaced matchers, to vary executation by earlier or later
  # content of a demo.
  #
  class Step

    # Ths demo to which the step belongs.
    # @return [Demo] demo
    attr :demo

    # Block lines code/text.
    #attr :lines

    # Previous step.
    # @return [Step] previous step
    attr :back_step

    # Next step.
    # @return [Step] next step
    attr :next_step

    # Step up a new step.
    #
    # @param [Demo] demo
    #   The demo to which the step belongs.
    #
    # @param [Array<Array<Integer,String>]] explain_lines
    #   The step's explaination text, broken down into an array
    #   of `[line number, line text]` entries.
    #
    # @param [Array<Array<Integer,String>]] example_lines
    #   The steps example text, broken down into an array
    #   of `[line number, line text]` entries.
    #
    # @param [Step] last
    #   The previous step in the demo.
    #
    def initialize(demo, explain_lines, example_lines, last)
      #QED.all_steps << self

      @demo = demo
      @file = demo.file

      #@lines = []

      @explain_lines = explain_lines
      @example_lines = example_lines

      @back_step = last
      @back_step.next_step = self if @back_step
    end

    # The step's explaination text, broken down into an array
    # of `[line number, line text]` entries.
    #
    # @return [Array<Array<Integer,String>]] explain_lines
    attr :explain_lines

    # The steps example text, broken down into an array
    # of `[line number, line text]` entries.
    #
    # @return [Array<Array<Integer,String>]] example_lines
    attr :example_lines

    # Ths file to which the step belongs.
    #
    # @return [String] file path
    def file
      demo.file
    end

    # Full text of block including both explination and example text.
    def to_s
      (@explain_lines + @example_lines).map{ |lineno, line| line }.join("")
    end

    # Description text.
    def explain
      @explain ||= @explain_lines.map{ |lineno, line| line }.join("")
    end

    # Alternate term for #explain.
    alias_method :description, :explain

    # @deprecated
    alias_method :text, :explain

    # TODO: Support embedded rule steps ?

    #
    #def rule?
    #  @is_rule ||= (/\A(given|when|rule|before|after)[:.]/i.match(text))
    #end

    #
    #def rule_text
    #  rule?.post_match.strip
    #end

    # TODO: better name than :proc ?

    # 
    def type
      assertive? ? :test : :proc
    end

    # A step is a heading if it's description starts with a '=' or '#'.
    def heading?
      @is_heading ||= (/\A[=#]/ =~ explain)
    end

    # Any commentary ending in `:` will mark the example
    # text as a plain text *sample* and not code to be evaluated.
    def data?
      @is_data ||= explain.strip.end_with?(':')
    end

    # Is the example text code to be evaluated?
    def code?
      !data? && example?
    end

    # First line of example text.
    def lineno
      @lineno ||= (
        if @example_lines.first
          @example_lines.first.first
        elsif @explain_lines.first
          @explain_lines.first.first
         else
          1
        end
      )
    end

    def explain_lineno
      @explain_lines.first ? @explain_lines.first.first : 1
    end

    def example_lineno
      @example_lines.first ? @example_lines.first.first : 1
    end

    # Does the block have an example?
    def example?
      ! example.strip.empty?
    end
    alias has_example? example?

    #
    def example
      @example ||= (
        if data?
          @example_lines.map{ |lineno, line| line }.join("")
        else
          tweak_code
        end
      )
    end
    alias_method :code, :example
    alias_method :data, :example

    # Returns any extra arguments the step passes along to rules.
    def arguments
      []
    end

    # Clean up the example text, removing unccesseary white lines
    # and triple quote brackets, but keep indention intact.
    #
    def clean_example
      str = example.chomp.sub(/\A\n/,'')
      if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(str)
        str = md[1]
      end
      str.rstrip
    end

    # TODO: We need to preserve the indentation for the verbatim reporter.
    #def clean_quote(text)
    #  text = text.tabto(0).chomp.sub(/\A\n/,'')
    #  if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(text)
    #    text = md[1]
    #  end
    #  text.rstrip
    #end

    # When the text is sample text and passed to an adivce block, this
    # provides the prepared form of the example text, removing white lines,
    # triple quote brackets and indention.
    #
    def sample_text
      str = example.tabto(0).chomp.sub(/\A\n/,'')
      if md = /\A["]{3,}(.*?)["]{3,}\Z/.match(str)
        str = md[1]
      end
      str.rstrip
    end

    # TODO: object_hexid
    def inspect
      str = text[0,24].gsub("\n"," ")
      %[\#<Step:#{object_id} "#{str} ...">]
    end

    #
    def assertive?
      @assertive ||= !text.strip.end_with?('^')
    end

  protected

    #
    def next_step=(n)
      @next_step = n
    end

  private

    #
    def tweak_code
      code = @example_lines.map{ |lineno, line| line }.join("")

      #code.gsub!(/\n\s*\#\ ?\=\>(.*?)$/, ' == \1 ? assert(true) : assert(false, %{not returned -- \1})')   # TODO: what kind of error ?
      #code.gsub!(/\s*\#\ ?\=\>(.*?)$/,   ' == \1 ? assert(true) : assert(false, %{not returned -- \1})')

      code.gsub!(/\n\s*\#\ ?\=\>\s*(.*?)$/, '.must_return(\1)')
      code.gsub!(/\s*\#\ ?\=\>\s*(.*?)$/, '.must_return(\1)')

      code
    end

  end

end
