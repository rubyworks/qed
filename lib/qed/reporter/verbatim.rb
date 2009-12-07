module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Verbatim Reporter
  #
  class Verbatim < BaseClass

    #def report_step(step)
    #  super
    #  if step.code
    #    #str = "(%s) %s" % [count.join('.'), str.tab(6).strip]
    #    #io.puts "* #{step.to_s.tab(2).strip}"
    #    #io.puts
    #    #io.puts step.to_s
    #    #io.puts
    #  else
    #    #io.puts "#{step}\n"  # TODO: This never happens.
    #  end
    #end

    #def report_intro
    #  io.puts
    #end

    def report_header(step)
      io.print ANSICode.bold("#{step}")
    end

    def report_comment(step)
      io.print step
    end

    #
    def report_macro(step)
      #io.puts
      #io.puts step.text
      io.print ANSICode.magenta("#{step}")
      #io.puts
    end

    #
    def report_pass(step)
      io.print ANSICode.green("#{step}")
    end

    def report_fail(step, error)
      tab = step.to_s.index(/\S/) #step.tab
      io.puts ANSICode.red("#{step}")
      #puts
      msg = []
      msg << ANSICode.bold(ANSICode.red("FAIL: ")) + error.to_str
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    def report_error(step, error)
      raise error if $DEBUG
      tab = step.to_s.index(/\S/) #step.tab
      io.puts ANSICode.red("#{step}")
      #io.puts
      msg = []
      msg << ANSICode.bold(ANSICode.red("ERROR: ")) + error.to_str.sub(/for QED::Context.*?$/,'')
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))
      #msg = ANSICode.red(msg)
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    def report_step_end(step)
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

