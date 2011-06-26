module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # Bullet Point Reporter - similar to the Verbose reporter, but does
  # not display test code for passing tests.
  #
  class BulletPoint < Abstract

    #
    def head(step)
      io.print "#{step}".ansi(:bold)
    end

    def desc(step)
      txt = step.to_s.strip.tabto(2)
      txt[0,1] = "*"
      io.puts txt
      io.puts
    end

    def pass(step)
      #io.puts "#{step}".ansi(:green)
    end

    def fail(step, assertion)
      backtrace = sane_backtrace(assertion)

      msg = []
      msg << "  " + "FAIL".ansi(:red)
      msg << ""
      msg << assertion.to_s.gsub(/^/, '  ')
      msg << ""
      backtrace.each do |bt|
        msg << "  " + relative_file(bt)
      end
      io.puts msg.join("\n")
      io.puts
      io.print step.text.tabto(4)
    end

    def error(step, exception)
      raise exception if $DEBUG

      backtrace = sane_backtrace(exception)

      msg = []
      msg << "  " + "ERROR".ansi(:red)
      msg << ""
      msg << "  " + exception.to_s
      msg << ""
      backtrace.each do |bt|
        msg << "  " + relative_file(bt)
      end
      io.puts msg.join("\n")
      io.puts
      io.print step.text.tabto(4)
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  io.puts str.strip
    #end

    #def report_comment(step)
    #  txt = step.to_s.strip.tabto(2)
    #  txt[0,1] = "*"
    #  io.puts txt
    #  io.puts
    #end

    #def report_macro(step)
    #  txt = step.to_s.tabto(2)
    #  txt[0,1] = "*"
    #  io.puts txt
    #  #io.puts
    #  #io.puts "#{step}".ansi(:magenta)
    #end

    def after_session(session)
      print_time
      print_tally
    end

  end #class Summary

end#module Reporter
end#module QED
