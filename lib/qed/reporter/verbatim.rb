module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Verbose ANSI Console Reporter
  #
  class Verbatim < BaseClass

    #
    def tag(element)
      case element.name
      when 'pre'
        # none
      when /h\d/
        io.print ANSI::Code.bold("#{element.text.strip}\n\n")
      when 'p'
        io.print "#{element.text.strip}\n\n"
      #when 'a'
      #  io.print element.to_s
      when 'ul', 'ol'
        io.print "\n"
      when 'li'
        io.print "* #{element.text.strip}\n"
      end
    end

    #
    def pass(step)
      txt = step.text.rstrip.sub("\n",'')
      io.print ANSI::Code.green("#{txt}\n\n")
    end

    #
    def fail(step, error)
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSI::Code.red("#{txt}\n\n")
      msg = []
      msg << ANSI::Code.bold(ANSI::Code.red("FAIL: ")) + error.to_str
      msg << ANSI::Code.bold(clean_backtrace(error.backtrace[0]))
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    #
    def error(step, error)
      raise error if $DEBUG
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSI::Code.red("#{txt}\n\n")
      msg = []
      msg << ANSI::Code.bold(ANSI::Code.red("ERROR: ")) + error.to_str.sub(/for QED::Context.*?$/,'')
      msg << ANSI::Code.bold(clean_backtrace(error.backtrace[0]))
      #msg = ANSICode.red(msg)
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
    #  puts ANSICode.magenta(set.to_yaml.tabto(2))
    #end

    #
    #def macro(step)
    #  #io.puts
    #  #io.puts step.text
    #  io.print ANSICode.magenta("#{step}")
    #  #io.puts
    #end

  end

end #module Reporter
end #module QED

