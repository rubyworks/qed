module QED
  require 'facets/dir/ascend'

  require 'ae'

  require 'qed/reporter/dotprogress'
  require 'qed/reporter/summary'
  require 'qed/reporter/verbatim'

  #Assertion   = AE::Assertion
  Expectation = Assertor

  # New Specification
  #def initialize(specs, output=nil)
  #  @specs  = [specs].flatten
  #end

  # = Script
  #
  class Script

    #def self.load(file, output=nil)
    #  new(File.read(file), output)
    #end

    attr :file
    attr :output

    # New Script
    def initialize(file, output=nil)
      @file   = file
      @output = output || Reporter::Verbatim.new #(self)

      source = File.read(file)
      index  = source.rindex('---') || source.size

      @source = source[0...index]
      @helper = source[index+3...-1].to_s.strip
    end

    #def convert
    #  @source.gsub(/^\w/, '# \1')
    #end

    # Run the script.
    def run
      #steps = @source.split(/\n\s*$/)
      eval(@helper, context._binding, @file) if @helper
      steps.each do |step|
        output.report_step(step)
        case step
        when /^[=#]/
          output.report_header(step)
        when /^\S/
          output.report_comment(step)
        else
          run_step(step)
        end
      end
    end

    #
    def run_step(step, &blk)
      context.before.call if context.before
      begin
        if blk
          blk.call #eval(step, context._binding)
        else
          eval(step, context._binding, @file) # TODO: would be nice to know file and lineno here
        end
        output.report_pass(step)
      rescue Assertion => error
        output.report_fail(step, error)
      rescue Exception => error
        output.report_error(step, error)
      ensure
        context.after.call if context.after
      end
    end

    # Cut-up script into steps.
    def steps
      @steps ||= (
        code  = false
        str   = ''
        steps = []
        @source.each_line do |line|
          if /^\s*$/.match line
            str << line
          elsif /^[=]/.match line
            steps << str.chomp("\n")
            steps << line.chomp("\n")
            str = ''
            #str << line
            code = false
          elsif /^\S/.match line
            if code
              steps << str.chomp("\n")
              str = ''
              str << line
              code = false
            else
              str << line
            end
          else
            if code
              str << line
            else
              steps << str
              str = ''
              str << line
              code = true
            end
          end
        end
        steps << str
        steps
      )
    end

    # The run context.
    def context
      @context ||= Context.new(self)
    end

  end

  #
  class Context < Module

    def initialize(script)
      @_script = script
    end

    def _binding
      @_binding ||= binding
    end

    # Set before step.
    def before(&f)
      @_before = f if f
      @_before
    end

    # Set after step.
    def after(&f)
      @_after = f if f
      @_after
    end

    # Table-based steps.
    def table(file=nil, &blk)
      require 'yaml'

      file ||= File.basename(@_script.file).chomp(File.extname(@_script.file)) + '.yaml'

      Dir.ascend(Dir.pwd) do |path|
        f1 = File.join(path, file)
        f2 = File.join(path, 'fixtures', file)
        fr = File.file?(f1) ? f1 : File.exist?(f2) ? f2 : nil
        (file = fr; break) if fr
      end

      tbl = YAML.load(File.new(file))
      tbl.each do |set|
        @_script.run_step(set.to_yaml.tabto(2)){ blk.call(set) }
        #@_script.output.report_table(set)
      end
    end

    def fixture(fname, content=nil)
      raise if File.directory?(fname)
      if content
        FileUtils.mkdir_p(File.dirname(fname))
        File.open(fname, 'w'){ |f| f << content }
      else
        raise LoadError, "no such fixture file -- #{fname}" unless File.exist?(fname)
        File.read(fname)
      end
    end

  end

end

