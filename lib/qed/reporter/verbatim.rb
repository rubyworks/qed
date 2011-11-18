module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = Verbose ANSI Console Reporter
  #
  class Verbatim < Abstract

    #
    def before_session(session)
      @start_time = Time.now

      trap "INFO" do
        print_time
        print_tally
      end if INFO_SIGNAL
    end

    #
    def rule(step)
      io.print "#{step.text}".ansi(:magenta)
      io.print "#{step.example}".ansi(:magenta)
    end

    #
    def pass(step)
      super(step)
      if step.heading?
        if step.code?
          io.print "#{step.text}".ansi(:bold, :green)
        else
          io.print "#{step.text}".ansi(:bold)
        end
      else
        io.print "#{step.text}".ansi(:green)
      end

      if step.has_example? 
        if step.data?
          io.print "#{step.example}".ansi(:magenta, :bold)
        else
          io.print "#{step.example}".ansi(:green, :bold)
        end
      end
    end

    #
    def fail(step, error)
      super(step, error)
      txt = step.text.rstrip #.sub("\n",'')
      tab = step.text.index(/\S/)
      io.print "#{txt}\n\n".ansi(:red)
      msg = []
      #msg << ANSI::Code.bold(ANSI::Code.red("FAIL: ")) + error.message
      #msg << ANSI::Code.bold(clean_backtrace(error.backtrace[0]))
      msg << "FAIL: ".ansi(:bold, :red) + error.message.to_s #to_str
      #msg << sane_backtrace(error).first.to_s.ansi(:bold)
      msg << sane_backtrace(error).join("\n").ansi(:bold)   # TODO: customizable backtrace size
      io.puts msg.join("\n").tabto(tab||2)
      io.puts
    end

    #
    def error(step, error)
      super(step, error)
      raise error if $DEBUG
      txt = step.text.rstrip #.sub("\n",'')
      tab = step.text.index(/\S/)
      io.print "#{txt}\n\n".ansi(:red)
      msg = []
      msg << "ERROR: #{error.class} ".ansi(:bold,:red) + error.message #.sub(/for QED::Context.*?$/,'')
      #msg << sane_backtrace(error).first.to_s.ansi(:bold)
      msg << sane_backtrace(error).join("\n").ansi(:bold)   # TODO: customizable backtrace size
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

    #
    def after_session(session)
      trap 'INFO', 'DEFAULT' if INFO_SIGNAL
      print_time
      print_tally
    end

  end

end #module Reporter
end #module QED
