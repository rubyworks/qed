module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # TAP-Y Reporter 
  #
  # NOTE: I suppose techincally that each TAP-Y test should be an assertion,
  # but that's a whole other ball of wax, and would require AE to remember
  # every assertion made. It also would have no means of providing an upfront
  # count.
  #
  class TapY < Abstract

    #
    def before_session(session)
      data = {
        'type'  => 'suite',
        'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        'count' => session.total_step_count
      }
      io.puts data.to_yaml
    end

    #
    # @todo How to get the line number so we can do proper snippets?
    def pass(step)
      super(step)

      lines = step.text.split("\n")
      #snip, l = [], step.line
      #lines.map do |line|
      #  snip << { (l += 1) => line }
      #end

      #if step.header?
      #  data = {
      #    'type'        => 'note',
      #    'description' => step.text, #.strip,
      #  }
      if step.code?
        data = {
          'type'        => 'test',
          'status'      => 'pass',
          'label'       => step.text.strip,
          #'file'        => step.file,
          #'line'        => step.line,
          #'returned'    => nil,
          #'expected'    => nil,
          'source'      => lines.first,
          'snippet'     => step.text.strip,
          'time'        => time_since_start
        }
      else
        data = {
          'type'        => 'test',
          'status'      => 'pass',
          'label'       => step.text.strip,
          #'file'        => step.file,
          #'line'        => step.line,
          #'returned'    => nil,
          #'expected'    => nil,
          'source'      => lines.first,
          'snippet'     => step.text.strip,
          'time'        => time_since_start
        }
      end
      io.puts data.to_yaml
    end

    #
    def fail(step, assertion)
      super(step, assertion)

      backtrace = sane_backtrace(assertion)

      file, line = file_line(backtrace)

      snippet = structured_code_snippet(assertion, bredth=3)
      source  = snippet.map{ |h| h.values.first }[snippet.size / 2].strip

      data = {
        'type'        => 'test',
        'status'      => 'fail',
        'label'       => step.text.strip,
        'file'        => file,
        'line'        => line,
        'message'     => assertion.to_s.unansi,
        'class'       => assertion.class.name,
        #'returned'    => nil,
        #'expected'    => nil,
        'source'      => source,
        'snippet'     => snippet,
        'time'        => time_since_start
      }

      io.puts data.to_yaml
    end

    #
    def error(step, exception)
      super(step, exception)

      backtrace = sane_backtrace(exception)

      file, line = file_line(backtrace)

      snippet = structured_code_snippet(exception, bredth=3)
      source  = snippet.map{ |h| h.values.first }[snippet.size / 2].strip

      data = {
        'type'        => 'test',
        'status'      => 'error',
        'label'       => step.text.strip,
        'file'        => file,
        'line'        => line,
        'message'     => exception.to_s.unansi,
        'class'       => exception.class.name,
        #'returned'    => nil,
        #'expected'    => nil,
        'backtrace'   => backtrace,
        'source'      => source,
        'snippet'     => snippet,
        'time'        => time_since_start
      }

      io.puts data.to_yaml
    end


=begin
    def fail(step, assertion)
      backtrace = sane_backtrace(assertion)

      msg = []
      msg << "  " + "FAIL".ansi(:red)
      msg << ""
      msg << assertion.to_s.gsub(/^/, '  ')
      msg << ""
      backtrace.each do |bt|
        msg << "  " + relative_file(bt)
      end
      io.puts msg.join("\n")
      io.puts
      io.print step.text.tabto(4)
    end

    def error(step, exception)
      raise exception if $DEBUG

      backtrace = sane_backtrace(exception)

      msg = []
      msg << "  " + "ERROR".ansi(:red)
      msg << ""
      msg << "  " + exception.to_s
      msg << ""
      backtrace.each do |bt|
        msg << "  " + relative_file(bt)
      end
      io.puts msg.join("\n")
      io.puts
      io.print step.text.tabto(4)
    end
=end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  io.puts str.strip
    #end

    #def report_comment(step)
    #  txt = step.to_s.strip.tabto(2)
    #  txt[0,1] = "*"
    #  io.puts txt
    #  io.puts
    #end

    #def report_macro(step)
    #  txt = step.to_s.tabto(2)
    #  txt[0,1] = "*"
    #  io.puts txt
    #  #io.puts
    #  #io.puts "#{step}".ansi(:magenta)
    #end

    def after_session(session)
      pass_size = steps.size - (fails.size + errors.size + omits.size)

      data = {
        'type'  => 'final',
        'tally' => {
           'total' => steps.size,
           'pass'  => pass_size,
           'fail'  => fails.size,
           'error' => errors.size,
           'omit'  => omits.size,
           'todo'  => 0
         },
         'time' => time_since_start
      }

      io.puts data.to_yaml
    end

    private

    #
    def time_since_start
      Time.now - @start_time
    end

  end

end#module Reporter
end#module QED
