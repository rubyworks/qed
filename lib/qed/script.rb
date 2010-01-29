module QED
  require 'yaml'
  require 'tilt'
  require 'nokogiri'
  require 'facets/dir/ascend'

  require 'ae'

  require 'qed/reporter/html'
  require 'qed/reporter/dotprogress'
  require 'qed/reporter/summary'
  require 'qed/reporter/verbatim'

  #Assertion   = AE::Assertion
  Expectation = Assertor

  # TODO: global before and after should be in an environment object

  @_before = { :all=>[], :each=>[] }
  @_after  = { :all=>[], :each=>[] }

  # Global Before
  def self.Before(type=:each, &procedure)
    @_before[type] << procedure if procedure
    @_before[type]
  end

  # Global After
  def self.After(type=:each, &procedure)
    @_after[type] << procedure if procedure
    @_after[type]
  end

  # = Script
  #
  class Script

    # Path of demonstration script.
    attr :file

    # Reporter object to issue output calls.
    attr :output

    # List of helper scripts to require.
    #attr :helpers

    # New Script
    def initialize(file, output=nil)
      @file   = file
      @output = output || Reporter::Verbatim.new #(self)
      parse
    end

    # File basename less extension.
    def name
      @name ||= File.basename(file).chomp(File.extname(file))
    end

    #
    def directory
      @directory ||= Dir.pwd #File.dirname(File.expand_path(file))
    end

    #def convert
    #  @source.gsub(/^\w/, '# \1')
    #end

    # Run the script.
    #--
    # TODO: lineno is all messed up, is there a way to get it from nokogiri?
    #++
    def run
      $LOAD_PATH.unshift(directory)

      import_helpers

      QED.Before(:all).each{ |f| f.call }
      context.Before(:all).each{ |f| f.call }

      begin
        root.traverse do |elem|
          output.report_step(elem)
          case elem.name
          when 'pre'
            run_step(elem)
          #when 'table'
          #  run_table(step)
          when 'p'
            context.When.each do |(regex, proc)|
              if md = regex.match(elem.text)
                proc.call(*md[1..-1])
              end
            end
          end
        end
      ensure
        QED.After(:all).each{ |f| f.call }
        context.After(:all).each{ |f| f.call }
        $LOAD_PATH.index(directory){ |i| $LOAD_PATH.delete_at(i) }
      end
    end

    #--
    # NOTE: The Around code is in place should we decide
    # to use it. I'm not sure yet if it's really neccessary,
    # since we have Before and After.
    #++
    def run_step(step)
      QED.Before(:each).each{ |b| b.call }
      context.Before(:each).each{ |b| b.call }
      begin
        #if context.Around
        #  context.Around.call do
        #    eval(step, context._binding, @file, @lineno+1)
        #  end
        #else
          eval(step.text, context._binding, file, step.line) #@lineno+1)
        #end
        output.report_pass(step)
      rescue Assertion => error
        output.report_fail(step, error)
      rescue Exception => error
        output.report_error(step, error)
      ensure
        context.After(:each).each{ |a| a.call }
        QED.After(:each).each{ |a| a.call }
      end
    end

=begin
    #
    def run_table(step)
      file = context.table
      Dir.ascend(Dir.pwd) do |path|
        f1 = File.join(path, file)
        f2 = File.join(path, 'fixtures', file)
        fr = File.file?(f1) ? f1 : File.exist?(f2) ? f2 : nil
        (file = fr; break) if fr
      end
      output.report_pass(step) #step)

      tbl = YAML.load(File.new(file))
      key = tbl.shift
      tbl.each do |set|
        assign = key.zip(set).map{ |k, v| "#{k}=#{v.inspect};" }.join
        run_table_step(assign + step, set)
        #run_step(set.inspect.tabto(4)){ blk.call(set) }
        #@_script.run_step(set.to_yaml.tabto(2)){ blk.call(set) }
        #@_script.output.report_table(set)
      end
      #output.report_pass(step) #step)
      context.table = nil
    end

    #
    #def run_table_step(step, set)
    def run_table_step(set, &blk)
      context.before.call if context.before
      begin
        #eval(step, context._binding, @file) # TODO: would be nice to know file and lineno here
        blk.call(*set)
        output.report_pass('    ' + set.inspect) #step)
      rescue Assertion => error
        output.report_fail(set.inspect, error)
      rescue Exception => error
        output.report_error(set.inspect, error)
      ensure
        context.after.call if context.after
      end
    end
=end

    #
    def parse
      nokogiri
    end

    # Convert and cache document to HTML.
    def html
      @html ||= to_html
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(to_html)
    end

    def root
      nokogiri.root
    end

    #
    def to_html
      require 'tilt'
      html = Tilt.new(file).render
      #puts html
      html
    end

    # TODO: Better way to select helpers.
    def helpers
      @helpers ||= (
        hlprs = []
        nokogiri.css('a').each do |elem|
          link = elem['href']
          if md = /helper\/(.*?)$/.match(link)
            hlprs << md[1]
          end
        end
        hlprs
      )
    end

    # The run context.
    def context
      @context ||= Context.new(self)
    end

    #
    def import(helper)
      code = File.read(helper)
      eval(code, context._binding)
    end

    #--
    # FIXME: where to stop looking for helpers.
    #++
    def import_helpers
      hlp = []
      dir = Dir.pwd #File.expand_path(dir)
      env = loop do
        helpers.each do |helper|
          file = File.join(dir, 'helpers', helper)
          if File.exist?(file)
            hlp << file
          end
        end
        break if ['qed', 'demo', 'demos', 'doc', 'docs', 'test', 'tests'].include? File.basename(dir)
        dir = File.dirname(dir)
      end
      hlp.each{ |helper| import(helper) }
    end

  private

=begin
    # Splits the document into main source and footer
    # and extract the helper document references from
    # the footer.
    #
    def parse_document(file)
      text  = File.read(file)
      index = text.rindex('---') || text.size
      source   = text[0...index]
      footer   = text[index+3..-1].to_s.strip
      #helpers  = parse_helpers(footer)
      @source = source
      @footer = footer
    end
=end

=begin
    #
    def parse_helpers(footer)
      helpers = []
      footer.split("\n").each do |line|
        next if line.strip == ''
        case line
        when /\[(.*?)\]\((.*?)\)/
          helpers << $2 
        when /(.*?)\[(.*?)\]/
          helpers << $2
        end
      end
      helpers
    end
=end

=begin
    # Looks for a master +helper.rb+ file and a special
    # helpers/<name>.rb file. Both of these, when found, will
    # be imported when this script is run.

    def collect_helpers
      dir  = File.dirname(file)
      list = []
      list << "helper.rb" if File.exist?(File.join(dir, "helper.rb"))
      list << "helpers/#{name}.rb" if File.exist?(File.join(dir, "helpers/#{name}.rb"))
      list
    end
=end

    # TODO: How to determine where to find the env.rb file?
    #def require_environment
    #  dir = File.dirname(file)
    #  dir = File.expand_path(dir)
    #  env = loop do
    #    file = File.join(dir, 'env.rb')
    #    break file if File.exist?(file)
    #    break nil  if ['demo', 'demos', 'doc', 'docs', 'test', 'tests'].include? File.basename(dir)
    #    break nil  if dir == Dir.pwd
    #    dir = File.dirname(dir)
    #  end
    #  require(env) if env
    #end

  end

  #
  class Context < Module

    #TABLE = /^TABLE\[(.*?)\]/i

    def initialize(script)
      @_script = script
      @_before = { :all=>[], :each=>[] }
      @_after  = { :all=>[], :each=>[] }
      @_when   = []
      @_tables = []
    end

    def _binding
      @_binding ||= binding
    end

    # Before steps.
    def Before(type=:each, &procedure)
      @_before[type] << procedure if procedure
      @_before[type]
    end

    # After steps.
    def After(type=:each, &procedure)
      @_after[type] << procedure if procedure
      @_after[type]
    end

    # Run code around each step.
    #
    # Around procedures must take a block, in which the step is run.
    #
    #   Around do |&step|
    #     ... do something here ...
    #     step.call
    #     ... do stiff stuff ...
    #   end
    #
    #def Around(&procedure)
    #  @_around = procedure if procedure
    #  @_around
    #end

    # Comment match procedure.
    #
    # This is useful for creating unobtrusive setup and (albeit more
    # limited) teardown code. A pattern is matched against each comment
    # as it is processed. If there is match, the code procedure is
    # triggered, passing in any mathcing expression arguments.
    #
    def When(pattern=nil, &procedure)
      return @_when unless procedure
      raise ArgumentError unless pattern
      unless Regexp === pattern
        pattern = __when_string_to_regexp(pattern)
      end
      @_when << [pattern, procedure]
    end

    # Code match-and-transform procedure.
    #
    # This is useful to transform human readable code examples
    # into proper exectuable code. For example, say you want to
    # run shell code, but want to make if look like typical
    # shelle examples:
    #
    #    $ cp fixture/a.rb fixture/b.rb
    #
    # You can use a transform to convert lines starting with '$'
    # into executable Ruby using #system.
    #
    #    system('cp fixture/a.rb fixture/b.rb')
    #
    #def Transform(pattern=nil, &procedure)
    #
    #end

    # Table-based steps.
    def Table(file=nil, &blk)
      file = file || @_tables.last
      tbl = YAML.load(File.new(file))
      tbl.each do |set|
        blk.call(*set)
      end
      @_tables << file
    end

    # Read/Write a fixture.
    def Data(file, &content)
      raise if File.directory?(file)
      if content
        FileUtils.mkdir_p(File.dirname(fname))
        case File.extname(file)
        when '.yml', '.yaml'
          File.open(file, 'w'){ |f| f << content.call.to_yaml }
        else
          File.open(file, 'w'){ |f| f << content.call }
        end
      else
        #raise LoadError, "no such fixture file -- #{fname}" unless File.exist?(fname)
        case File.extname(file)
        when '.yml', '.yaml'
          YAML.load(File.new(file))
        else
          File.read(file)
        end
      end
    end

  private

    def __when_string_to_regexp(str)
      str = str.split(/(\(\(.*?\)\))(?!\))/).map{ |x|
        x =~ /\A\(\((.*)\)\)\z/ ? $1 : Regexp.escape(x)
      }.join
      str = str.gsub(/(\\\ )+/, '\s+')
      Regexp.new(str, Regexp::IGNORECASE)

      #rexps = []
      #str = str.gsub(/\(\((.*?)\)\)/) do |m|
      #  rexps << '(' + $1 + ')'
      #  "\0"
      #end
      #str = Regexp.escape(str)
      #rexps.each do |r|
      #  str = str.sub("\0", r)
      #end
      #str = str.gsub(/(\\\ )+/, '\s+')
      #Regexp.new(str, Regexp::IGNORECASE)
    end

    # 
    # check only local and maybe start paths
    #def __locate_file(file)
    #  Dir.ascend(Dir.pwd) do |path|
    #    f1 = File.join(path, file)
    #    f2 = File.join(path, 'fixtures', file)
    #    fr = File.file?(f1) ? f1 : File.exist?(f2) ? f2 : nil
    #    (file = fr; break) if fr
    #  end
    #end

  end

end

