module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Summary Reporter
  #
  # Similar to the Verbatim reporter, but does
  # not display test code for passing tests.
  class Summary < BaseClass

    def report_header(step)
      io.puts ANSICode.bold("#{step}")
    end

    def report_comment(step)
      txt = step.to_s.strip.tabto(2)
      txt[0,1] = "*"
      io.puts txt
      io.puts
    end

    def report_macro(step)
      txt = step.to_s.tabto(2)
      txt[0,1] = "*"
      io.puts txt
      #io.puts
      #io.puts ANSICode.magenta("#{step}")
    end

    def report_pass(step)
      #io.puts ANSICode.green("#{step}")
    end

    def report_fail(step, assertion)
      msg = ''
      msg << "  ##### FAIL #####\n"
      msg << "  # " + assertion.to_s
      msg = ANSICode.magenta(msg)
      io.puts msg
      #io.puts
      io.puts ANSICode.red("#{step}")
    end

    def report_error(step, exception)
      raise exception if $DEBUG
      msg = ''
      msg << "  ##### ERROR #####\n"
      msg << "  # " + exception.to_s + "\n"
      msg << "  # " + exception.backtrace[0]
      msg = ANSICode.magenta(msg)
      io.puts msg
      #io.puts
      io.puts ANSICode.red("#{step}")
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  io.puts str.strip
    #end

  end #class Summary

end#module Reporter
end#module QED

