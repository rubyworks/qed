module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = DotProgress Reporter
  #
  class DotProgress < BaseClass

    #
    def report_intro
      @start_time = Time.now
      io.puts "Started"
    end

    #
    def report_step(step)
      super
      #if step.code
        io.print "."
        #str = "(%s) %s" % [count.join('.'), str.tab(6).strip]
        #puts "* #{step.text.tab(2).strip}"
        #puts "\n#{step.code}\n" if $VERBOSE
      #else
        #puts "\n#{step.text}"
      #end
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  puts str.strip
    #end

    def report_summary
      io.puts "\nFinished in #{Time.now - @start_time} seconds.\n\n"

      @error.each do |step, exception|
        io.puts ANSICode.red("***** ERROR *****")
        io.puts "#{exception}"
        io.puts ":#{exception.backtrace[0]}:"
        #io.puts ":#{exception.backtrace[1]}:"
        #io.puts exception.backtrace[1..-1] if $VERBOSE
        io.puts
      end

      @fail.each do |step, assertion|
        io.puts ANSICode.red("***** FAIL *****")
        io.puts ANSICode.bold("#{assertion}")
        io.puts ":#{assertion.backtrace[2]}:"
        #io.puts assertion if $VERBOSE
        io.puts
      end

      io.puts "%s specs, %s steps, %s failures, %s errors" % [@specs, @steps, @fail.size, @error.size] #, @pass.size ]
    end

  end#class DotProgress

end#module Reporter
end#module QED

