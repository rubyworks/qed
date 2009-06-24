module Respect
module Reporter #:nodoc:

  require 'respect/reporter/base'

  # = Verbatim Reporter
  #
  class Verbatim < BaseClass

    #def report_step(step)
    #  super
    #  if step.code
    #    #str = "(%s) %s" % [count.join('.'), str.tab(6).strip]
    #    #puts "* #{step.to_s.tab(2).strip}"
    #    #puts
    #    #puts step.to_s
    #    #puts
    #  else
    #    #puts "#{step}\n"  # TODO: This never happens.
    #  end
    #end

    def report_header(step)
      puts ANSICode.bold("#{step}")
      #puts
    end

    def report_comment(step)
      puts step
      #puts
    end

    #
    def report_macro(step)
      #puts
      #puts step.text
      puts ANSICode.magenta("#{step}")
      #puts
    end

    #
    def report_pass(step)
      puts ANSICode.green("#{step}")
      #puts
    end

    def report_fail(step, error)
      tab = step.to_s.index(/\S/) #step.tab
      puts ANSICode.red("#{step}")
      #puts
      msg = []
      msg << ANSICode.bold(ANSICode.red("FAIL: ")) + error.to_str
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))          
      puts msg.join("\n").tabto(tab||2)
      puts
    end

    def report_error(step, error)
      raise error if $DEBUG
      tab = step.to_s.index(/\S/) #step.tab
      puts ANSICode.red("#{step}")
      #puts
      msg = []
      msg << ANSICode.bold(ANSICode.red("ERROR: ")) + error.to_str.sub(/for Quarry::Context.*?$/,'')
      msg << ANSICode.bold(error.backtrace[0].chomp(":in \`_binding'"))
      #msg = ANSICode.red(msg)
      puts msg.join("\n").tabto(tab||2)
      puts
    end

    def report_step_end(step)
      puts
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

end #module
end #module Respect

