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
        backtrace = sane_backtrace(exception)

        io.puts "***** ERROR *****".ansi(:red)
        io.puts "#{exception}"
        backtrace.each do |bt|
          io.puts bt
          io.puts code_snippet(bt)
        end
        io.puts
      end

      fails.each do |step, assertion|
        backtrace = sane_backtrace(assertion)

        io.puts "***** FAIL *****".ansi(:red, :bold)
        io.puts "#{assertion}"
        backtrace.each do |bt|
          io.puts bt
          io.puts code_snippet(bt)
        end
        io.puts
      end

      print_tally
    end

  end#class DotProgress

end#module Reporter
end#module QED

