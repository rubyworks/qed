module QED

  # A Step consists of a flush region of text and the indented 
  # text the follows it. QED breaks all demo documents down into
  # these for evaluation.
  #
  class Step

    # Block lines code/text.
    attr :lines

    # Previous step.
    attr :back_step

    # Next step.
    attr :next_step

    #
    def initialize(file)
      QED.all_steps << self

      @file = file

      @lines = []

      @text_lines = []
      @code_lines = []

      @back_step = nil
      @next_step = nil
    end

    #
    def ready!(back_step)
      @back_step = back_step
      @back_step.next_step = self if @back_step
      self
    end

    #
    def <<(lineno_line_type)
      lineno, line, type = *lineno_line_type
      @lines << [lineno, line]
      if type == :code
        @code_lines << [lineno, line]
      else
        @text_lines << [lineno, line]
      end       
    end

    # Full text of block.
    def to_s
      lines.map{ |lineno, line| line }.join("")
    end

    # Description text.
    def text
      @text ||= @text_lines.map{ |lineno, line| line }.join("")
    end

    # Returns an Array of prepared example text
    # for use in advice.
    def arguments
      if data?
        [sample_text]
      else
        []
      end
    end

    # Three types of steps are `standard`, `header` or `rule`.
    #
    # Note: this has changed from 2.x series which used to define
    # type as `head`, `desc`, `code` or `data`. But since the
    # description and example text have merged into a single Step
    # instead of separate steps for 3.x series, this had to change.
    def type
      case text
      when /\A[=#]/
        :header
      when /\A(given|when)[:.]\ /i
        :rule
      else
        :standard
      end
    end

    #
    def rule?
      @is_rule ||= (/\A(given|when[:.]) /i =~ text)    
    end

    #
    def header?
      @is_header ||= (/\A[=#]/ =~ text)
    end
    alias head? header?

    # TODO: better name for description?

    #
    def description?
      !(header? or rule?)
    end
    alias desc? description?

    # Any commentary ending in `...` or `:` will mark the example
    # text as a plain text *sample* and not code to be evaluated.
    def data?
      @is_data ||= (/(\.\.\.|\:)\s*\Z/m =~ text.strip)
    end

    # Is the example text code to be evaluated?
    def code?
      ! data?
    end

    # First line of example text.
    def lineno
      @lineno ||= @lines.first.first
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
          @code_lines.map{ |lineno, line| line }.join("")
        else
          tweak_code
        end
      )
    end

    #
    alias_method :code, :example

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
      %[\#<Block:#{object_id} "#{str} ...">]
    end

  protected

    #
    def next_step=(n)
      @next_step = n
    end

  private

    #
    def tweak_code
      code = @code_lines.map{ |lineno, line| line }.join("")
      code.gsub!(/\n\s*\#\ ?\=\>/, '.assert = ')
      code.gsub!(/\s*\#\ ?\=\>/, '.assert = ')
      code
    end

  end

end
