module QED

  module Step

    # Base class for all types of steps.
    #
    class Base

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
        @type ||= self.class.name.split('::').last.downcase.to_sym
      end

      #
      def rule_text
        rule?.post_match.strip
      end

      #
      def heading?
        @is_heading ||= (/\A[=#]/ =~ text)
      end

      # Any commentary ending in `...` or `:` will mark the example
      # text as a plain text *sample* and not code to be evaluated.
      def data?
        @is_data ||= (/(\.\.\.|\:)\s*\Z/m =~ text.strip)
      end

      # Is the example text code to be evaluated?
      def code?
        !data? && example?
      end

      # First line of example text.
      def lineno
        @lineno ||= @explain_lines.first ? @explain_lines.first.first : 1
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

      # Returns an Array of prepared example text
      # for use in advice.
      def arguments
        if data?
          [sample_text]
        else
          []
        end
      end

      # Clean up the example text, removing unccesseary white lines
      # and triple quote brackets, but keep indention intact.
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
        false
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

    end

  end

end
