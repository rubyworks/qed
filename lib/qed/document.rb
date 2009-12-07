require 'erb'
require 'fileutils'

module QED

  # = Document
  #
  # TODO: css and javascripts have fixed location need to make more flexible.
  # TODO: Have option to run documents through the runner and color code output; need htmlreporter.
  #
  class Document

    DEFAULT_TITLE  = "Demonstration"
    DEFAULT_CSS    = nil #"../assets/styles/spec.css"
    DEFAULT_OUTPUT = "doc/qedoc"
    DEFAULT_PATH   = "test/demos"

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
        dir = Dir['{test/demos,demo,demos}'].first || DEFAULT_PATH
        @paths  = File.join(dir, '**', '*')
      end
    end

    # Demo files.
    def demo_files
      @demo_files ||= (
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

        case ext
        #when '.qed'
        #  require_qedoc
        #  markup = Markup.new(File.read(file))
        #  text << markup.to_html
        when '.rd', '.rdoc'
          require_rdoc
          markup = RDoc::Markup::ToHtml.new
          text << markup.convert(txt)
          #text << markup.convert(iotext, formatter)
        when '.md', '.markdown'
          require_rdiscount
          markdown = RDiscount.new(txt)
          text << markdown.to_html
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
      @require_rdoc ||= (
        require 'qed/document/markup'
        true
      )
    end

    #
    def require_rdoc
      @require_rdoc ||= (
        require 'rdoc/markup/to_html'
        #require 'rdoc/markup/simple_markup'
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

