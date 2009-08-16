module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = DotProgress Reporter
  #
  class DotProgress < BaseClass

    #
    def report_intro
      @start_time = Time.now
      puts "Started"
    end

    #
    def report_step(step)
      super
      #if step.code
        print "."
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
      puts "\nFinished in #{Time.now - @start_time} seconds.\n\n"

      @error.each do |step, exception|
        puts ANSICode.red("***** ERROR *****")
        puts "#{exception}"
        puts ":#{exception.backtrace[0]}:"
        #puts ":#{exception.backtrace[1]}:"
        #puts exception.backtrace[1..-1] if $VERBOSE
        puts
      end

      @fail.each do |step, assertion|
        puts ANSICode.red("***** FAIL *****")
        puts ANSICode.bold("#{assertion}")
        puts ":#{assertion.backtrace[2]}:"
        #puts assertion if $VERBOSE
        puts
      end

      puts "%s specs, %s steps, %s failures, %s errors" % [@specs, @steps, @fail.size, @error.size] #, @pass.size ]
    end

  end#class DotProgress

end#module Reporter
end#module QED

