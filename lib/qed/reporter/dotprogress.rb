module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = DotProgress Reporter
  #
  class DotProgress < Abstract

    #
    def before_session(session)
      @start_time = Time.now
      io.puts "Started"
    end

    #
    #def before_step(step)
    #  super(step)
    #  io.print "."
    #  io.flush
    #end

    def pass(step)
      io.print "."
      io.flush
      super(step)
    end

    def fail(step, assertion)
      io.print "F"
      io.flush
      super(step, assertion)
    end

    def error(step, exception)
      io.print "E"
      io.flush
      super(step, exception)
    end

    #
    def after_session(session)
      print_time

      errors.each do |step, exception|
        backtrace = clean_backtrace(exception.backtrace[0])
        io.puts "***** ERROR *****".ansi(:red)
        io.puts "#{exception}"
        io.puts ":#{backtrace}:"
        #io.puts ":#{exception.backtrace[1]}:"
        #io.puts exception.backtrace[1..-1] if $VERBOSE
        io.puts code_snippet(exception)
        io.puts
      end

      fails.each do |step, assertion|
        backtrace = clean_backtrace(assertion.backtrace[0])
        io.puts "***** FAIL *****".ansi(:red)
        io.puts "#{assertion}".ansi(:bold)
        io.puts ":#{backtrace}:"
        # -- io.puts assertion if $VERBOSE
        io.puts code_snippet(assertion)
        io.puts
      end

      print_tally
    end

  end#class DotProgress

end#module Reporter
end#module QED

