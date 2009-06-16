require 'erb'
require 'fileutils'

module Quarry

  # = Document
  #
  # TODO: css and javascripts have fixed location
  # -     need to make more flexible.
  class Document

    DEFAULT_TITLE = "Specifications"
    DEFAULT_CSS   = nil #"../assets/styles/spec.css"
    DEFAULT_FILE  = "doc/spec/index.html"
    DEFAULT_PATH  = ["spec/**/*"]

    attr_accessor :title
    attr_accessor :css
    attr_accessor :paths
    attr_accessor :dryrun
    attr_accessor :quiet

    # Ouput file.
    attr_accessor :output    

    # New Spec Document object.
    def initialize(options)
      options.each do |k,v|
        __send__("#{k}=", v)
      end

      @title  ||= DEFAULT_TITLE
      @css    ||= DEFAULT_CSS
      @output ||= DEFAULT_FILE
      @paths  ||= []

      @paths  = DEFAULT_PATH if @paths.empty?
    end

    # Supress output.
    def quiet? ; @quiet ; end

    # Generate specification document.
    def generate
      text  = ''
      files = []
      paths.each do |path|
        files.concat(Dir.glob(path).select{ |f| File.file?(f) })
      end
      files.sort!
      files.each do |file|
        puts file unless quiet?
        case ext = File.extname(file)
        when '.rd', '.rdoc'
          require_rdoc
          markup = SM::SimpleMarkup.new
          formatter = SM::ToHtml.new
          text << markup.convert(File.read(file), formatter)
        when '.md', '.markdown'
          # TODO
        end
        text << "\n"
      end

      temp = Template.new(template, text, title, css)
      html = temp.parse_template

      save(html)
    end

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
        puts "\nwrite #{output}"
      else
        FileUtils.mkdir_p(File.dirname(output))
        File.open(output, 'wb') do |f|
          f << text
        end
      end
    end

  private

    #
    def require_rdoc
      @require_rdoc ||= (
        require 'rdoc/markup/simple_markup'
        require 'rdoc/markup/simple_markup/to_html'
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

