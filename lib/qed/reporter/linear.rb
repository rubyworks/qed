module QED
module Reporter #:nodoc:

  require 'ansi/terminal'
  require 'qed/reporter/abstract'

  # Linear reporter limits each step to a single line.
  #
  class Linear < Abstract

    #
    def before_session(session)
      @width = ANSI::Terminal.terminal_width - 6
      @start_time = Time.now
      puts "[#{timestamp}] Session @ #{Time.now}"
    end

    #
    def before_demo(demo)
      file = localize_file(demo.file)
      post
      puts "[#{timestamp}] Demo #{file}".ansi(:bold)
    end

    #
    def before_proc(step)
      super(step)
      post
      str = "[#{timestamp}] Step #{step.explain.gsub(/\s+/,' ')} "[0,@width]
      pad = @width - str.size + 1
      print str + (' ' * pad)
    end

    #
    def pass(step)
      super(step)

      print_step(step, :green)

      s = []

      s << "PASS".ansi(:green)

      puts s.join("\n")
    end

    #
    def fail(step, assertion)
      super(step, assertion)

      print_step(step, :red)

      puts "FAIL".ansi(:red)

      s = []
      s << assertion.class.name
      s << assertion.message

      backtrace = sane_backtrace(assertion)
      backtrace.each do |bt|
        s << bt
        s << code_snippet(bt)
      end

      puts s.join("\n").tabto(13)
    end

    #
    def error(step, exception)
      super(step, exception)

      print_step(step, :red)

      puts "ERROR".ansi(:red)

      s = []
      s << assertion.class.name
      s << assertion.message

      backtrace = sane_backtrace(assertion)
      backtrace.each do |bt|
        s << bt
        s << code_snippet(bt)
      end

      puts s.join("\n").tabto(13)
    end

    #
    def after_session(session)
      puts "[#{timestamp}] %s demos, %s steps: %s failures, %s errors (%s/%s assertions)" % get_tally
      puts "[#{timestamp}] Finished in %.5f seconds." % [Time.now - @start_time]
      puts "[#{timestamp}] End Session."
    end

  private

    def timestamp
      Time.now.strftime('%H:%M:%S')
    end

    #
    def print(str)
      @appendable = true
      io.print str
    end

    #
    def puts(str)
      @appendable = false
      io.puts str
    end

    #
    def post
      io.puts if @appendable
      @appendable = false
    end

    #
    def print_step(step, *color)
      post
      str = "[#{timestamp}] Step #{step.explain.gsub(/\s+/,' ')} "[0,@width]
      pad = @width - str.size + 1
      print (str + (' ' * pad)).ansi(*color)
    end
  end

end#module Reporter
end#module QED
