module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Verbatim Reporter
  # TODO: rename to Verbose ?
  class Verbatim < BaseClass

    def report_step(step)
      case step.name
      when 'pre'
        # none
      when /h\d/
        io.print ANSICode.bold("#{step.text.strip}\n\n")
      when 'p'
        io.print "#{step.text.strip}\n\n"
      end
    end

    #def report_intro
    #  io.puts
    #end

    #def report_header(step)
    #  io.print ANSICode.bold("#{step}")
    #end

    #def report_comment(step)
    #  io.print step
    #end

    #
    #def report_macro(step)
    #  #io.puts
    #  #io.puts step.text
    #  io.print ANSICode.magenta("#{step}")
    #  #io.puts
    #end

    #
    def report_pass(step)
      txt = step.text.rstrip.sub("\n",'')
      io.print ANSICode.green("#{txt}\n\n")
    end

    def report_fail(step, error)
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSICode.red("#{txt}\n")
      msg = []
      msg << ANSICode.bold(ANSICode.red("FAIL: ")) + error.to_str
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))
      io.puts msg.join("\n").tabto(tab||2)
      #io.puts
    end

    def report_error(step, error)
      raise error if $DEBUG
      txt = step.text.rstrip.sub("\n",'')
      tab = step.text.index(/\S/) - 1
      io.print ANSICode.red("#{txt}\n")
      msg = []
      msg << ANSICode.bold(ANSICode.red("ERROR: ")) + error.to_str.sub(/for QED::Context.*?$/,'')
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))
      #msg = ANSICode.red(msg)
      io.puts msg.join("\n").tabto(tab||2)
      #io.puts
    end

    #def report_step_end(step)
    #  io.puts
    #end

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

