module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = DotProgress Reporter
  #
  class DotProgress < BaseClass

    #
    def before_session(session)
      @start_time = Time.now
      io.puts "Started"
    end

    #
    def before_step(step)
      super(step)
      io.print "." if step.name == 'pre'
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  puts str.strip
    #end

    def after_session(session)
      io.puts "\nFinished in #{Time.now - @start_time} seconds.\n\n"

      @error.each do |step, exception|
        backtrace = clean_backtrace(exception.backtrace[0])
        io.puts ANSICode.red("***** ERROR *****")
        io.puts "#{exception}"
        io.puts ":#{backtrace}:"
        #io.puts ":#{exception.backtrace[1]}:"
        #io.puts exception.backtrace[1..-1] if $VERBOSE
        io.puts
      end

      @fail.each do |step, assertion|
        backtrace = clean_backtrace(assertion.backtrace[0])
        io.puts ANSICode.red("***** FAIL *****")
        io.puts ANSICode.bold("#{assertion}")
        io.puts ":#{backtrace}:"
        #io.puts assertion if $VERBOSE
        io.puts
      end

      io.puts "%s demos, %s steps, %s failures, %s errors" % [@demos, @steps, @fail.size, @error.size] #, @pass.size ]
    end

  end#class DotProgress

end#module Reporter
end#module QED

