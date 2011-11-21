module QED
module Reporter #:nodoc:

  require 'ansi/terminal'
  require 'qed/reporter/abstract'

  # Linear reporter limits each step to a single line.
  #
  class Linear < Abstract

    #
    def before_session(session)
      @width = ANSI::Terminal.terminal_width - 12
      @start_time = Time.now
      puts "[INFO] Session @ #{Time.now}".ansi(:bold)
    end

    #
    def before_demo(demo)
      file = localize_file(demo.file)
      puts "[DEMO] #{file}".ansi(:bold)
    end

    #
    def before_applique(step)
      super(step)
      #post
      str = "[NOTE] #{step.explain.gsub(/\s+/,' ')} "[0,@width]
      pad = @width - str.size + 1
      print str + (' ' * pad)
      puts "[#{timestamp}]"
    end

    #
    def pass(step)
      super(step)

      print_step(step, 'PASS', :green)

      #s = []
      #s << "PASS".ansi(:green)
      #puts s.join("\n")
    end

    #
    def fail(step, assertion)
      super(step, assertion)

      print_step(step, 'FAIL', :red)

      #puts "FAIL".ansi(:red)

      s = []
      s << assertion.class.name
      s << assertion.message

      backtrace = sane_backtrace(assertion)
      backtrace.each do |bt|
        s << bt
        s << code_snippet(bt)
      end

      puts s.join("\n").tabto(8)
    end

    #
    def error(step, exception)
      super(step, exception)

      print_step(step, 'ERRO', :red)

      #puts "ERROR".ansi(:red)

      s = []
      s << assertion.class.name
      s << assertion.message

      backtrace = sane_backtrace(assertion)
      backtrace.each do |bt|
        s << bt
        s << code_snippet(bt)
      end

      puts s.join("\n").tabto(8)
    end

    #
    def after_session(session)
      puts "[INFO] %s demos, %s steps: %s failures, %s errors (%s/%s assertions)" % get_tally
      puts "[INFO] Finished in %.5f seconds." % [Time.now - @start_time]
      puts "[INFO] End Session @ #{Time.now}".ansi(:bold)
    end

  private

    def timestamp
      (Time.now - @start_time).to_s[0,8]
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
    def print_step(step, stat, *color)
      desc = step.explain.gsub(/\s+/,' ')
      if desc.start_with?('=') or desc.start_with?('#')
        desc = desc.ansi(:magenta)
      end
      str = "[#{stat}] #{desc} "[0,@width]
      pad = @width - str.unansi.size + 1
      print (str + (' ' * pad)).ansi(*color)
      puts "[#{timestamp}]"
    end
  end

end#module Reporter
end#module QED
