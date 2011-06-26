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
    DEFAULT_OUTPUT = "qedoc"
    DEFAULT_PATH   = "qed"

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

      if @paths.empty?
        #dir = Dir['{test/demos,demos,demo}'].first || DEFAULT_PATH
        #@paths  = File.join(dir, '**', '*')
        abort "No files to document."
      end
    end

    # Demo files.
    def demo_files
      @demo_files ||= (
        glob = paths.map do |f|
          File.directory?(f) ? Dir[File.join(f,'**/*')] : Dir[f]
        end
        glob = glob.flatten.select do |f|
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

      output = ''
      files  = []

      #paths.each do |path|
      #  files.concat(Dir.glob(path).select{ |f| File.file?(f) })
      #end
      #files.sort!

      #TODO: load .config/qedrc.rb

      demo_files.each do |file|
        puts file unless quiet?

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
          markup = Markup.new(txt)
          text << markup.to_html
          #text << markup.convert(iotext, formatter)
        when '.md', '.markdown'
          require_rdiscount
          markdown = RDiscount.new(txt)
          text << markdown.to_html
        end

        output << "#{text}\n"
      end

      temp = Template.new(template, output, title, css)
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
        require 'qedoc/document/markup'
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

