module QED

  # A Step consists of a flush region of text and the indented 
  # text the follows it. QED breaks all demo documents down into
  # these for evaluation.
  #
  class Step

    #
    attr :file

    # Block lines code/text.
    attr :lines

    # Previous step.
    attr :back_step

    # Next step.
    attr :next_step

    #
    def initialize(file, explain, example, last)
      QED.all_steps << self

      @file = file

      #@lines = []

      @explain_lines = explain
      @example_lines = example

      @back_step = last
      @back_step.next_step = self if @back_step
    end

    #
    #def <<(lineno_line_type)
    #  lineno, line, type = *lineno_line_type
    #  @lines << [lineno, line]
    #  if type == :code
    #    @example << [lineno, line]
    #  else
    #    @explain << [lineno, line]
    #  end       
    #end

    # Full text of block.
    def to_s
      (@explain_lines + @example_lines).map{ |lineno, line| line }.join("")
    end

    # Description text.
    def explain
      @explain ||= @explain_lines.map{ |lineno, line| line }.join("")
    end
    alias_method :text, :explain
    alias_method :description, :explain

    #
    def rule?
      @is_rule ||= (/\A(given|when|rule|before|after)[:.]/i.match(text))
    end

    #
    def type
      :eval #@type ||= self.class.name.split('::').last.downcase.to_sym
    end

    #
    def rule_text
      rule?.post_match.strip
    end

    #
    def heading?
      @is_heading ||= (/\A[=#]/ =~ text)
    end

    # Any commentary ending in `:` will mark the example
    # text as a plain text *sample* and not code to be evaluated.
    def data?
      @is_data ||= text.strip.end_with?(':')
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

    #
    def evaluate(demo)
      evaluate_matchers(demo)
      demo.evaluate(code, lineno) if code?
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
      code.gsub!(/\n\s*\#\ ?\=\>/, '.assert = ')
      code.gsub!(/\s*\#\ ?\=\>/, '.assert = ')
      code
    end

    #
    def evaluate_matchers(demo)
      match = text

      demo.applique.each do |app|
        app.__matchers__.each do |(patterns, proc)|
          compare = match
          matched = true
          params  = []
          patterns.each do |pattern|
            case pattern
            when Regexp
              regex = pattern
            else
              regex = match_string_to_regexp(pattern)
            end
            if md = regex.match(compare)
              params.concat(md[1..-1])
              compare = md.post_match
            else
              matched = false
              break
            end
          end
          if matched
            #args = [params, arguments].reject{|e| e == []}  # use single argument for params in 3.0?
            args = params
            args = args + [sample_text] if data?
            args = proc.arity < 0 ? args : args[0,proc.arity]

            demo.scope.instance_exec(*args, &proc)  #proc.call(*args)
          end
        end
      end
    end

    SPLIT_PATTERNS = [ /(\(\(.*?\)\)(?!\)))/, /(\/\(.*?\)\/)/, /(\/\?.*?\/)/ ]

    SPLIT_PATTERN  = Regexp.new(SPLIT_PATTERNS.join('|'))

    # Convert matching string into a regular expression. If the string
    # contains double parenthesis, such as ((.*?)), then the text within
    # them is treated as in regular expression and kept verbatium.
    #
    def match_string_to_regexp(str)
      re = nil
      str = str.split(SPLIT_PATTERN).map do |x|
        case x
        when /\A\(\((.*?)\)\)(?!\))/
          $1
        when /\A\/(\(.*?\))\//
          $1
        when /\A\/(\?.*?)\//
          "(#{$1})"
        else
          Regexp.escape(x)
        end
      end.join

      str = str.gsub(/\\\s+/, '\s+')  # Replace space with variable space.

      Regexp.new(str, Regexp::IGNORECASE)
    end

=begin
    # The following code works as well, and can provide a MatchData
    # object instead of just matching params, but I call YAGNI on that
    # and it has two benefits. 1) the above code is faster, and 2)
    # using params allows |(name1, name2)| in rule blocks.

    #
    def evaluate_matchers(step)
      match = step.text
      args  = step.arguments
      @demo.applique.each do |a|
        matchers = a.__matchers__
        matchers.each do |(patterns, proc)|
          re = build_matcher_regexp(*patterns)
          if md = re.match(match)
            #params = [step.text.strip] + params
            #proc.call(*params)
            @demo.scope.instance_exec(md, *args, &proc)
          end
        end
      end
    end

    #
    def build_matcher_regexp(*patterns)
      parts = []
      patterns.each do |pattern|
        case pattern
        when Regexp
          parts << pattern
        else
          parts << match_string_to_regexp(pattern)
        end
      end
      Regexp.new(parts.join('.*?'), Regexp::MULTILINE)
    end
=end

  end

end
