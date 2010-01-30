module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Verbose ANSI Console Reporter
  #
  class Verbatim < BaseClass

    #
    def before_step(step)
      case step.name
      when 'pre'
        # none
      when /h\d/
        io.print ANSI::Code.bold("#{step.text.strip}\n\n")
      when 'p'
        io.print "#{step.text.strip}\n\n"
      end
    end

    #
    #def macro(step)
    #  #io.puts
    #  #io.puts step.text
    #  io.print ANSICode.magenta("#{step}")
    #  #io.puts
    #end

    #
    def step_pass(step)
      txt = step.text.rstrip.sub("\n",'')
      io.print ANSI::Code.green("#{txt}\n\n")
    end

    #
    def step_fail(step, error)
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSI::Code.red("#{txt}\n")
      msg = []
      msg << ANSI::Code.bold(ANSICode.red("FAIL: ")) + error.to_str
      msg << ANSI::Code.bold(clean_backtrace(error.backtrace[0]))
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    #
    def step_error(step, error)
      raise error if $DEBUG
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSI::Code.red("#{txt}\n")
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

  end

end #module Reporter
end #module QED

