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
    def before_step(step, file)
      super(step, file)
      io.print "."
      io.flush
    end

    #
    def after_session(session)
      io.puts "\nFinished in #{Time.now - @start_time} seconds.\n\n"

      @error.each do |step, exception|
        backtrace = clean_backtrace(exception.backtrace[0])
        io.puts "***** ERROR *****".ansi(:red)
        io.puts "#{exception}"
        io.puts ":#{backtrace}:"
        #io.puts ":#{exception.backtrace[1]}:"
        #io.puts exception.backtrace[1..-1] if $VERBOSE
        io.puts
      end

      @fail.each do |step, assertion|
        backtrace = clean_backtrace(assertion.backtrace[0])
        io.puts "***** FAIL *****".ansi(:red)
        io.puts "#{assertion}".ansi(:bold)
        io.puts ":#{backtrace}:"
        # -- io.puts assertion if $VERBOSE
        io.puts
      end

      mask = "%s demos, %s steps: %s failures, %s errors (%s/%s assertions)"
      vars = [@demos, @steps, @fail.size, @error.size, $assertions-$failures, $assertions] #, @pass.size ]

      io.puts mask % vars 
    end

  end#class DotProgress

end#module Reporter
end#module QED

