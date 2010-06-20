module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = Bullet Point Reporter
  #
  # Similar to the Verbose reporter, but does
  # not display test code for passing tests.
  class BulletPoint < Abstract

    #
    def text(step)
      case step.text
      when /^\=/
        io.print "#{step.text}".ansi(:bold)
      else
        txt = step.text.to_s.strip.tabto(2)
        txt[0,1] = "*"
        io.puts txt
        io.puts
      end
    end

    def pass(step)
      #io.puts "#{step}".ansi(:green)
    end

    def fail(step, assertion)
      msg = ''
      msg << "  ##### FAIL #####\n"
      msg << "  # " + assertion.to_s
      msg = msg.ansi(:magenta)
      io.puts msg
      io.print "#{step.text}".ansi(:red)
    end

    def error(step, exception)
      raise exception if $DEBUG
      msg = ''
      msg << "  ##### ERROR #####\n"
      msg << "  # " + exception.to_s + "\n"
      msg << "  # " + clean_backtrace(exception.backtrace[0])
      msg = msg.ansi(:magenta)
      io.puts msg
      io.print "#{step.text}".ansi(:red)
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

  end #class Summary

end#module Reporter
end#module QED

