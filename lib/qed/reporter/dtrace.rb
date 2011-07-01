module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  #  Deep trace reporter
  #
  class DTrace < Abstract

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
      super(step)
    end

    #
    def fail(step, assertion)
      super(step, assertion)

      io.puts "#{assertion}".ansi(:red)

      backtrace = sane_backtrace(assertion)
      backtrace.each do |bt|
        io.puts bt
        io.puts code_snippet(bt)
      end

      io.puts
    end

    #
    def error(step, exception)
      super(step, exception)

      io.puts "#{exception}".ansi(:red)

      backtrace = sane_backtrace(exception)
      backtrace.each do |bt|
        io.puts bt
        io.puts code_snippet(bt)
      end

      io.puts
    end


    #
    def after_session(session)
      print_time
      print_tally
    end

  end

end#module Reporter
end#module QED
