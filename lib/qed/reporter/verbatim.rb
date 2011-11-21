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

    def step(step)
      @_explain = step.explain.dup
    end

    #
    def match(step, md)
      unless md[0].empty?
        @_explain.sub!(md[0], md[0].ansi(:bold))
      end
    end

    #
    def applique(step)
      io.print "#{@_explain}".ansi(:cyan)
      io.print "#{step.example}" #.ansi(:blue)
    end

    #
    def pass(step)
      super(step)
      if step.heading?
        if step.code?
          io.print "#{@_explain}".ansi(:bold, :cyan)
        else
          io.print "#{@_explain}".ansi(:bold)
        end
      else
        io.print "#{@_explain}".ansi(:cyan)
      end

      if step.has_example? 
        if step.data?
          io.print "#{step.example}" #.ansi(:magenta)
        else
          io.print "#{step.example}".ansi(:green)
        end
      end
    end

    #
    def fail(step, error)
      super(step, error)

      tab = step.text.index(/\S/)

      if step.heading?
        if step.code?
          io.print "#{@_explain}".ansi(:bold, :magenta)
        else
          io.print "#{@_explain}".ansi(:bold)
        end
      else
        io.print "#{@_explain}".ansi(:magenta)
      end

      if step.has_example? 
        if step.data?
          io.print "#{step.example}".ansi(:red)
        else
          io.print "#{step.example}".ansi(:red)
        end
      end

      msg = []
      msg << "FAIL: ".ansi(:bold, :red) + error.message.to_s #to_str
      msg << sane_backtrace(error).join("\n").ansi(:bold)
      msg = msg.join("\n")

      io.puts msg.tabto(tab||2)
      io.puts
    end

    #
    def error(step, error)
      super(step, error)

      raise error if $DEBUG   # TODO: Should this be here?

      tab = step.text.index(/\S/)

      if step.heading?
        if step.code?
          io.print "#{@_explain}".ansi(:bold, :magenta)
        else
          io.print "#{@_explain}".ansi(:bold)
        end
      else
        io.print "#{@_explain}".ansi(:magenta)
      end

      if step.has_example? 
        if step.data?
          io.print "#{step.example}".ansi(:red)
        else
          io.print "#{step.example}".ansi(:red)
        end
      end

      msg = []
      msg << "ERROR: #{error.class} ".ansi(:bold,:red) + error.message #.sub(/for QED::Context.*?$/,'')
      msg << sane_backtrace(error).join("\n").ansi(:bold)
      msg = msg.join("\n") #.ansi(:red)

      io.puts msg.tabto(tab||2)
      io.puts
    end

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
