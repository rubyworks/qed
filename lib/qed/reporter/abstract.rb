module QED
module Reporter

  require 'facets/string'

  begin
    require 'ansi/core'
  rescue LoadError
    require 'ansi/code'
  end

  # = Reporter Absract Base Class
  #
  # Serves as the base class for all other output formats.
  class Abstract

    # Does the system support INFO signal?
    INFO_SIGNAL = Signal.list['INFO']

    #
    attr :session

    #
    attr :io

    #
    attr :record

    # TODO: pass session into initialize
    def initialize(options={})
      @io    = options[:io] || STDOUT
      @trace = options[:trace]

      @record = {
        :demo  => [],
        :step  => [],
        :omit  => [],
        :pass  => [],
        :fail  => [],
        :error => []
      }

      #@demos = 0
      #@steps = 0
      #@omit  = []
      #@pass  = []
      #@fail  = []
      #@error = []

      @source = {}
    end

    def demos  ; @record[:demo]  ; end
    def steps  ; @record[:step]  ; end
    def omits  ; @record[:omit]  ; end
    def passes ; @record[:pass]  ; end
    def errors ; @record[:error] ; end
    def fails  ; @record[:fail]  ; end

    #
    def trace?
      @trace
    end

    #
    def success?
      record[:error].size + record[:fail].size == 0
    end

    #
    def call(type, *args)
      __send__("count_#{type}", *args) if respond_to?("count_#{type}")
      __send__(type, *args) if respond_to?(type)
    end

    def self.When(type, &block)
      #raise ArgumentError unless %w{session demo demonstration step}.include?(type.to_s)
      #type = :demonstration if type.to_s == 'demo'
      define_method(type, &block)
    end

    def self.Before(type, &block)
    #  raise ArgumentError unless %w{session demo demonstration step}.include?(type.to_s)
    #  type = :demonstration if type.to_s == 'demo'
      define_method("before_#{type}", &block)
    end

    def self.After(type, &block)
    #  raise ArgumentError unless %w{session demo demonstration step pass fail error}.include?(type.to_s)
    #  type = :demonstration if type.to_s == 'demo'
      define_method("after_#{type}", &block)
    end

    #
    #def Before(type, target, *args)
    #  type = :demonstration if type.to_s == 'demo'
    #  __send__("before_#{type}", target, *args)
    #end

    #
    #def After(type, target, *args)
    #  type = :demonstration if type.to_s == 'demo'
    #  __send__("after_#{type}", target, *args)
    #end

    def count_demo(demo)
      @record[:demo] << demo
    end

    def count_step(step)
      @record[:step] << step
    end

    #def count_eval(step)
    #  @record[:eval] << step
    #end

    def count_pass(step)
      @record[:pass] << step
    end

    def count_fail(step, exception)
      @record[:fail] << [step, exception]
    end

    def count_error(step, exception)
      @record[:error] << [step, exception]
    end


    # At the start of a session, before running any demonstrations.
    def before_session(session)
      @session    = session
      @start_time = Time.now
    end

    # Beginning of a demonstration.
    def before_demo(demo) #demo(demo)
      #demos << demo
    end

    #
    def before_import(file)
    end

    #
    def before_step(step)
    end

    #
    def before_proc(step)
    end

    #
    def before_eval(step)
    end

    # Before running a step that is omitted.
    #def before_omit(step)
    #  @omit << step
    #end

    # Reight before demo.
    def demo(demo)
    end

    # Right before import.
    def import(file)
    end

    # Right before rule section.
    def rule(step)
    end

    # Right before text section.
    def step(step)  #show text ?
    end

    # Right before evaluation.
    def proc(step)
    end

    # Right before evaluation.
    def eval(step)
    end

    # Right before evaluation.
    #def code(step)
    #end

    # After running a step that passed.
    def pass(step)
      #@pass << step
    end

    # After running a step that failed.
    def fail(step, assertion)
      ## @fail << [step, assertion]
    end

    # After running a step that raised an error.
    def error(step, exception)
      raise exception if $DEBUG  # TODO: do we really want to do it like this?
      ## @error << [step, exception]
    end

    #
    def after_import(file)
    end

    #
    def after_eval(step)
    end

    #
    def after_proc(step)
    end

    #
    def after_step(step)
    end

    # End of a demonstration.
    def after_demo(demo)  #demo(demo)
    end

    # After running all demonstrations. This is the place
    # to output a summary of the session, if applicable.
    def after_session(session)
    end

  private

    def print_time
      io.puts "\nFinished in %.5f seconds.\n\n" % [Time.now - @start_time]
    end

    def print_tally
      #assert_count = AE::Assertor.counts[:total]
      #assert_fails = AE::Assertor.counts[:fail]
      #assert_delta = assert_count - assert_fails

      mask = "%s demos, %s steps: %s failures, %s errors (%s/%s assertions)"
      #vars = [demos.size, steps.size, fails.size, errors.size, assert_delta, assert_count] #, @pass.size ]

      io.puts mask % get_tally
    end

    #
    def get_tally
      assert_count = $ASSERTION_COUNTS[:total]
      assert_fails = $ASSERTION_COUNTS[:fail]
      assert_delta = assert_count - assert_fails

      vars = [demos.size, steps.size, fails.size, errors.size, assert_delta, assert_count] #, @pass.size ]

      vars 
    end

    # TODO: Use global standard for backtrace exclusions.
    INTERNALS = /(lib|bin)[\\\/](qed|ae)/

    #
    def sane_backtrace(exception)
      if trace_count
        clean_backtrace(*exception.backtrace[0, trace_count])
      else
        clean_backtrace(*exception.backtrace)
      end
    end

    #
    def clean_backtrace(*btrace)
      stack = if $DEBUG
                btrace
              else
                btrace.reject{ |bt| bt =~ INTERNALS }
              end
      stack.map do |bt|
        bt.chomp(":in \`__binding__'")
      end
    end

=begin
    # Clean the backtrace of any reference to ko/ paths and code.
    def clean_backtrace(backtrace)
      trace = backtrace.reject{ |bt| bt =~ INTERNALS }
      trace.map do |bt| 
        if i = bt.index(':in')
          bt[0...i]
        else
          bt
        end
      end
    end
=end

    # Produce a pretty code snippet given an exception.
    #
    # @param exception [Exception, String]
    #   An exception or backtrace.
    #
    # @param radius [Integer]
    #   The number of surrounding lines to show.
    #
    # @return [String] pretty code snippet
    def code_snippet(exception, radius=2)
      radius = radius.to_i

      file, lineno = file_and_line(exception)

      return nil if file.empty?
      return nil if file == '(eval)'

      source = source(file)
      
      region = [lineno - radius, 1].max ..
               [lineno + radius, source.length].min

      # ensure proper alignment by zero-padding line numbers
      format = " %2s %0#{region.last.to_s.length}d %s"

      pretty = region.map do |n|
        format % [('=>' if n == lineno), n, source[n-1].chomp]
      end #.unshift "[#{region.inspect}] in #{source_file}"

      pretty
    end

    # Return a structure code snippet in an array of lineno=>line 
    # hash elements.
    #
    # @param exception [Exception, String]
    #   An exception or backtrace.
    #
    # @param radius [Integer]
    #   The number of surrounding lines to show.
    #
    # @return [Hash] structured code snippet
    def structured_code_snippet(exception, radius=2)
      radius = radius.to_i

      file, lineno = file_and_line(exception)

      return {} if file.empty?

      source = source(file)    

      region = [lineno - radius, 1].max ..
               [lineno + radius, source.length].min

      region.map do |n|
        {n => source[n-1].chomp}
      end
    end

    # Cache the source code of a file.
    #
    # @param file [String] full pathname to file
    #
    # @return [String] source code
    def source(file)
      @source[file] ||= (
        if File.exist?(file)
          File.readlines(file)
        else
          ''
        end
      )
    end

    # @param exception [Exception,Array,String]
    #   An exception or backtrace.
    #
    #--
    # TODO: Show more of the file name than just the basename.
    #++
    def file_and_line(exception)
      backtrace = case exception
                  when Exception
                    exception.backtrace.reject{ |bt| bt =~ INTERNALS }.first
                  when Array
                    exception.first
                  else
                    exception
                  end

      backtrace =~ /(.+?):(\d+(?=:|\z))/ or return ""

      file, lineno = $1, $2.to_i

      return file, lineno

      #i = backtrace.rindex(':in')
      #line = i ? line[0...i] : line
      #relative_file(line)
    end

    # Same as file_and_line, exception return file path is relative.
    def file_line(exception)
      file, lineno = file_and_line(exception)
      return relative_file(file), lineno
    end

    # Default trace count. This is the number of backtrace lines that
    # will be provided on errors and failed assertions, unless otherwise
    # overridden with ENV['trace'].
    DEFAULT_TRACE_COUNT = 3

    # Looks at ENV['trace'] to determine how much trace output to provide.
    # If it is not set, or set to`false` or `off`, then the default trace count
    # is used. If set to `0`, `true`, 'on' or 'all' then aa complete trace dump
    # is provided. Otherwise the value is converted to an integer and that many
    # line of trace is given.
    #
    # @return [Integer, nil] trace count
    def trace_count
      cnt = ENV['trace']
      case cnt
      when nil, 'false', 'off'
        DEFAULT_TRACE_COUNT
      when 0, 'all', 'true', 'on'
        nil
      else
        Integer(cnt)
      end
    end

    #
    def relative_file(file)
      pwd = Dir.pwd
      idx = (0...pwd.size).find do |i|
        file[i,1] != pwd[i,1]
      end
      idx ||= 1
      file[(idx-1)..-1]
    end

    #
    def localize_file(file)
      j = 0
      [file.to_s.size, Dir.pwd.size].max.times do |i|
        if Dir.pwd[i,1] != file[i,1]
          break j = i
        end
      end
      file[j..-1]
    end

  end

end
end

