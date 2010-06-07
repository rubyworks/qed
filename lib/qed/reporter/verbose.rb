module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = Verbose ANSI Console Reporter
  #
  class Verbose < Abstract

    #
    def tag(element)
      case element.name
      when 'pre'
        # none
      when /h\d/
        io.print "#{element.inner_html.strip}\n\n".ansi(:bold)
      when 'p'
        io.print "#{element.inner_html.strip}\n\n"
      #when 'a'
      #  io.print element.to_s
      when 'ul', 'ol'
        io.print ""
      when 'li'
        io.print "* #{element.text.strip}\n"
      end
    end

    #
    def end_tag(element)
      case element.name
      when 'ul', 'ol'
        io.print "\n"
      end
    end

    #
    def pass(step)
      txt = step.text.rstrip.sub("\n",'')
      io.print "#{txt}\n\n".ansi(:green)
    end

    #
    def fail(step, error)
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print "#{txt}\n\n".ansi(:red)
      msg = []
      #msg << ANSI::Code.bold(ANSI::Code.red("FAIL: ")) + error.to_str
      #msg << ANSI::Code.bold(clean_backtrace(error.backtrace[0]))
      msg << "FAIL: ".ansi(:bold, :red) + error.to_str
      msg << clean_backtrace(error.backtrace[0]).ansi(:bold)
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    #
    def error(step, error)
      raise error if $DEBUG
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print "#{txt}\n\n".ansi(:red)
      msg = []
      msg << "ERROR: #{error.class} ".ansi(:bold,:red) + error.to_str #.sub(/for QED::Context.*?$/,'')
      msg << clean_backtrace(error.backtrace[0]).ansi(:bold)
      #msg = msg.ansi(:red)
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  puts str.strip
    #end

    #def report_table(set)
    #  puts set.to_yaml.tabto(2).ansi(:magenta)
    #end

    #
    #def macro(step)
    #  #io.puts
    #  #io.puts step.text
    #  io.print "#{step}".ansi(:magenta)
    #  #io.puts
    #end

  end

end #module Reporter
end #module QED

