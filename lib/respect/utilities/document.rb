require 'erb'
require 'fileutils'

module Respect

  # = Document
  #
  # TODO: css and javascripts have fixed location
  # -     need to make more flexible.
  class Document

    DEFAULT_TITLE  = "Specifications"
    DEFAULT_CSS    = nil #"../assets/styles/spec.css"
    DEFAULT_OUTPUT = "doc/spec"
    DEFAULT_PATH   = ["spec/**/*"]

    attr_accessor :title
    attr_accessor :css
    attr_accessor :paths
    attr_accessor :dryrun
    attr_accessor :quiet

    # Ouput file.
    attr_accessor :output    

    # New Spec Document object.
    def initialize(options={})
      options.each do |k,v|
        __send__("#{k}=", v)
      end

      @title  ||= DEFAULT_TITLE
      @css    ||= DEFAULT_CSS
      @output ||= DEFAULT_OUTPUT
      @paths  ||= []

      @paths  = DEFAULT_PATH if @paths.empty?
    end

    # Specification files.
    def spec_files
      @spec_files ||= (
        glob = paths.map{ |f| File.directory?(f) ? Dir["#{f}/**/*"] : Dir[f] }.flatten
        glob = glob.select do |f|
          File.file?(f) && f !~ /fixtures\/|helpers\// && f !~ /\.rb$/
        end
        glob.sort
      )
    end

    # Supress output.
    def quiet? ; @quiet ; end

    # Generate specification document.
    def generate
      copy_support_files

      text  = ''
      files = []

      #paths.each do |path|
      #  files.concat(Dir.glob(path).select{ |f| File.file?(f) })
      #end
      #files.sort!

      spec_files.each do |file|
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

    #
    def copy_support_files
      make_output_directory
      %w{jquery.js}.each do |fname|
        file = File.join(File.dirname(__FILE__), 'document', fname)
        FileUtils.cp(file, output)
      end
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
        make_output_directory
        File.open(output + '/index.html', 'wb') do |f|
          f << text
        end
      end
    end

    def make_output_directory
      FileUtils.mkdir_p(output)
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

