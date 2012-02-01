require 'erb'
require 'fileutils'
#require 'nokogiri'

module QED

  # = Document
  #
  # TODO: css and javascripts have fixed location need to make more flexible.
  # TODO: Have option to run documents through the runner and color code output; need htmlreporter.
  #
  class Document

    DEFAULT_TITLE  = "Demonstration"
    DEFAULT_CSS    = nil #"../assets/styles/spec.css"
    DEFAULT_OUTPUT = "qed.html"
    DEFAULT_PATH   = "qed"

    attr_accessor :title

    attr_accessor :css

    attr_accessor :dryrun

    attr_accessor :quiet

    # Ouput file.
    attr_accessor :output

    # Format of output file, either 'html' or 'plain'.
    # Defaults to extension of output file.
    attr_accessor :format

    # Files to document.
    attr_reader :paths

    #
    def paths=(paths)
      @paths = [paths].flatten
    end

    # New Spec Document object.
    def initialize(options={})
      options.each do |k,v|
        __send__("#{k}=", v)
      end

      @paths  ||= []

      @output ||= DEFAULT_OUTPUT
      @title  ||= DEFAULT_TITLE
      @css    ||= DEFAULT_CSS

      if File.directory?(@output)
        @output = File.join(@output, 'qed.html')
      end

      @format ||= File.extname(@output).sub('.','')

      if @paths.empty?
        #dir = Dir['{test/demos,demos,demo}'].first || DEFAULT_PATH
        #@paths  = File.join(dir, '**', '*')
        abort "No files to document."
      end
    end

    # Demo files.
    def demo_files
      @demo_files ||= (
        files = []
        paths.each do |f|
          if File.directory?(f)
            files.concat Dir[File.join(f,'**','*')]
          else
            files.concat Dir[f]
          end
        end
        files = files.reject{ |f| File.directory?(f) }
        files = files.reject{ |f| File.extname(f) == '.rb' }
        files = files.reject{ |f| /(fixtures|helpers)\// =~ f }

        # doesn't include .rb applique but does markup applique
        applique, files = files.partition{ |f| /applique\// =~ f }

        applique.sort + files.sort
      )
    end

    # Supress output.
    def quiet?
      @quiet
    end

    # Generate specification document.
    #
    #--
    # TODO: Use Malt to support more formats in future.
    #++
    def generate
      #copy_support_files

      out   = ''
      files = []

      #paths.each do |path|
      #  files.concat(Dir.glob(path).select{ |f| File.file?(f) })
      #end
      #files.sort!

      if dryrun or $DEBUG
        puts demo_files.sort.join(" ")
      end

      demo_files.each do |file|
        #strio = StringIO.new('')
        #reporter = Reporter::Html.new(strio)
        #runner = Runner.new([file], reporter)
        #runner.check
        #iotext = strio.string
        #strio.close

        ext = File.extname(file)
        txt = File.read(file)

        if ext == '.qed'
          ext = file_type(txt)
        end

        #text = Tilt.new(file).render
        #html = Nokogiri::HTML(text)
        #body = html.css("body")

        text = ""
        case ext
        #when '.qed'
        #  require_qedoc
        #  markup = Markup.new(File.read(file))
        #  text << markup.to_html
        when '.rd', '.rdoc'
          require_rdoc
          require_qedoc
          if html?
            markup = Markup.new(txt)
            text << markup.to_html
            #text << markup.convert(iotext, formatter)
          else
            text << txt
          end        
        when '.md', '.markdown'
          require_rdiscount
          if html?
            markdown = RDiscount.new(txt)
            text << markdown.to_html
          else
            text << txt
          end
        end

        # TODO: Use Nokogiri to find all <pre>'s with preceeding <p>'s that have text ending in `:`, and
        # add the class `no-highlight`. If no preceeding `:` add class ruby.

        out << "#{text}\n"
      end

      if html?
        temp = Template.new(template, out, title, css)
        html = temp.parse_template
        save(html)
      else
        save(out)
      end
    end

    #
    def html?
      format == 'html'
    end

    #
    #def copy_support_files
    #  make_output_directory
    #  %w{jquery.js}.each do |fname|
    #    file = File.join(File.dirname(__FILE__), 'document', fname)
    #    FileUtils.cp(file, output)
    #  end
    #end

    # Load specification HTML template.
    def template
      @template ||= (
        file = File.join(File.dirname(__FILE__), 'document', 'template.rhtml')
        File.read(file)
      )
    end

    # Save specification document.
    def save(text)
      if dryrun
        puts "[dry-run] Write #{output}" unless quiet
      else
        make_output_directory
        File.open(output, 'wb') do |f|
          f << text
        end
        puts "Write #{output}" unless quiet
      end
    end

    def make_output_directory
      dir = File.dirname(output)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

  private

    #
    def file_type(text)
      rdoc = text.index(/^\=/)
      markdown = text.index(/^\#/)
      if markdown && rdoc
        rdoc < markdown ? '.rdoc' : '.markdown'
      elsif rdoc
        '.rdoc'
      elsif markdown
        '.markdown'
      else  # fallback to rdoc
        '.rdoc'
      end
    end

    #
    def require_qedoc
      @require_qedoc ||= (
        require 'qed/document/markup'
        true
      )
    end

    #
    def require_rdoc
      @require_rdoc ||= (
        begin
          require 'rdoc/markup/to_html'
        rescue LoadError
          require 'rubygems'
          gem 'rdoc'
          retry
        end
        true
      )
    end

    #
    def require_rdiscount
      @require_rdiscount ||= (
        require 'rdiscount'
        true
      )
    end

  end

  # = Document Template
  #
  class Template
    attr :spec
    attr :title
    attr :css

    #
    def initialize(template, spec, title, css)
      @template = template
      @spec     = spec
      @title    = title
      @css      = css
    end

    def parse_template
      erb = ERB.new(@template)
      erb.result(binding)
    end
  end

end

