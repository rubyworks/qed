module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = Verbose ANSI Console Reporter
  #
  class Verbatim < Abstract

    #
    def text(section)
      text = section.commentary
      text = text.gsub(/^([=#].*?)$/, '\1'.ansi(:bold))
      io.print text
      if section.continuation?
        io.puts(section.clean_example.ansi(:blue))
        io.puts
      end
    end

    # headers ?

    #
    def pass(step)
      txt = step.example #.rstrip.sub("\n",'')
      io.print "#{txt}".ansi(:green)
    end

    #
    def fail(step, error)
      txt = step.example.rstrip #.sub("\n",'')
      tab = step.example.index(/\S/)
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
      txt = step.example.rstrip #.sub("\n",'')
      tab = step.example.index(/\S/)
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

