module Respect

  require 'respect/grammar/expect'
  require 'respect/grammar/assert'
  require 'respect/grammar/should'

  require 'respect/reporter/dotprogress'
  require 'respect/reporter/summary'
  require 'respect/reporter/verbatim'

  # New Specification
  #def initialize(specs, output=nil)
  #  @specs  = [specs].flatten
  #end

  # = Script
  #
  class Script

    def self.load(file, output=nil)
      new(File.read(file), output)
    end

    attr :output

    # New Script
    def initialize(source, output=nil)
      @source = source
      @output = output || Reporter::Verbatim.new #(self)
    end

    #def convert
    #  @source.gsub(/^\w/, '# \1')
    #end

    # Run the script.
    def run
      #steps = @source.split(/\n\s*$/)
      steps.each do |step|
        case step
        when /^\S/
          puts step
        else
          context.before.call if context.before
          begin
            eval(step, context._binding)
            output.report_pass(step)
          rescue Assertion => error
            output.report_fail(step, error)
          rescue Exception => error
            output.report_error(step, error)
          ensure
            context.after.call if context.after
          end
        end
      end
    end

    # Cut-up script into steps.
    def steps
      @steps ||= (
        code  = false
        str   = ''
        steps = []
        @source.each_line do |line|
          if line =~ /^\s*$/
            str << line
          elsif line =~ /^\S/
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
        steps
      )
    end

    # The run context.
    def context
      @context ||= Context.new
    end

  end

  #
  class Context < Module

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

    # Table-based step.
    # TODO
    def table(file)
    end

  end

end


