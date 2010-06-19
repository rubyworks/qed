module QED
  require 'yaml'
  require 'tilt'
  require 'nokogiri'

  require 'facets/dir/ascend'

  require 'qed/parser'
  require 'qed/evaluator'

  # = Script
  #
  class Script

    #
    attr :applique

    # Demonstrandum file.
    attr :file

    #
    attr :scope

    # New Script
    def initialize(applique, file, scope=nil)
      @applique = applique.dup # localize copy of applique
      @file     = file
      @scope    = scope || Scope.new(applique)
      @binding  = @scope.__binding__
      #@loadlist = []
      #apply_environment
    end

    # One binding per script.
    def binding
      @binding #||= @scope.__binding__
    end

    #
    def advice
      #@scope.__advice__
      @applique.__advice__
    end

    # Expanded dirname of +file+.
    def directory
      @directory ||= File.expand_path(File.dirname(file))
    end

    # File basename less extension.
    def name
      @name ||= File.basename(file).chomp(File.extname(file))
    end

=begin
    # Nokogiri HTML document.
    def document
      @document ||= normalize_html(html)
    end

    # Root node of the html document.
    def root
      document.root
    end

    # Open file and translate template into HTML text.
    def to_html
      #case file
      #when /^http/
      #  ext  = File.extname(file).sub('.','')
      #  Tilt[ext].new{ source }
      #else
      #end
      if File.extname(file) == '.html'
        html = File.read(file)
      else
        html = Tilt.new(file).render
      end
      html
    end

    # While converting various forms of plain text markup
    # to HTML tends to create simalarly constructed HTML
    # markup, there are some differences, as well as some
    # chracter encodings that are not helpful when processing
    # via applique, which are generally defined in simple ASCII.
    #
    # This method is therefore used to further normalize and
    # simplfy the generate HTML.
    def normalize_html(html)
      #html.gsub!("\342\200\246", '...')
      html.gsub!("&#8216;", "'")
      html.gsub!("&#8217;", "'")
      html.gsub!("&#8220;", '"')
      html.gsub!("&#8221;", '"')

      document = Nokogiri::HTML(html)
      document.root.traverse do |node|
        if node.name == 'p'
          ellipse = Regexp.escape("\342\200\246")
          if /([.]{3,3}|#{ellipse})\s*\Z/.match(node.text)
            n = node.next_sibling
            until Nokogiri::XML::Element === n
              n = n.next_sibling
            end
            if n
              pre = (n.name == 'pre' ? n : n.at('pre'))
              if pre
                pre['class'] = 'quote'
                pre.unlink
                node.add_child(pre)
              end
            end
          end
        end
      end
      #puts document if $DEBUG && $VERBOSE
      document
    end

    # Open, convert to HTML and cache.
    def html
      @html ||= to_html
    end
=end

    #
    #def source
    #  @source ||= (
    #    #case file
    #    #when /^http/
    #    #  ext  = File.extname(file).sub('.','')
    #    #  open(file)
    #    #else
    #      File.read(file)
    #    #end
    #  )
    #end

    def parse
      Parser.new(file).parse
    end

    #
    def run(*observers)
      evaluator = Evaluator.new(self, *observers)
      evaluator.run
    end

  end

end

