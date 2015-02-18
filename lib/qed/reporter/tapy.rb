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
      @start_time = Time.now

      data = {
        'type'  => 'suite',
        'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        'count' => session.total_step_count,
        'rev'   => 2
      }
      io.puts data.to_yaml
    end

    # TODO: Handle cases by file or by headers?
    def demo(demo)
      data = {
        'type'    => 'case',
        'subtype' => 'demo',
        'label'   => localize_file(demo.file),
        'level'   => 0
      }
      io.puts data.to_yaml
    end

    #
    # @todo How to get the line number so we can do proper snippets?
    def pass(step)
      super(step)

      source_line = lines = step.text.split("\n")

      #snip, l = [], step.line
      #lines.map do |line|
      #  snip << { (l += 1) => line }
      #end

      #if step.header?
      #  data = {
      #    'type'        => 'note',
      #    'description' => step.text, #.strip,
      #  }

      data = {
          'type'    => 'test',
          'subtype' => 'step',
          'status'  => 'pass',
          'label'   => step.text.strip,
          'file'    => localize_file(step.file),
          'line'    => step.lineno,
          'time'    => time_since_start
      }

          #'returned' => nil,
          #'expected' => nil,

      if step.example?
        if step.code?
          data.merge!(
            'source'  => step.example_lines.first.last.strip,
            'snippet' => step.example_lines.map{ |n, l| {n => l.rstrip} }
          )
        else
          data.merge!( 
            'source'  => step.example_lines.first.last.strip,
            'snippet' => step.example_lines.map{ |n, l| {n => l.rstrip} }
          )
        end
      else
        #data.merge!(
        #  'source'  => step.explain_lines.first.first,
        #  'snippet' => step.sample_text
        #)
      end

      io.puts data.to_yaml
    end

    #
    def fail(step, assertion)
      super(step, assertion)

      backtrace = sane_backtrace(assertion)

      file, line = file_line(backtrace)
      file = localize_file(file)

      snippet = structured_code_snippet(assertion, bredth=3)
      source  = snippet.map{ |h| h.values.first }[snippet.size / 2].strip

      data = {
        'type'        => 'test',
        'subtype'     => 'step',
        'status'      => 'fail',
        'label'       => step.explain.strip,
        'file'        => localize_file(step.file),
        'line'        => step.explain_lineno,
        #'returned'    => nil,
        #'expected'    => nil,
        'time'        => time_since_start,
        'exception'   => {
          'message'   => assertion.message, #unansi
          'class'     => assertion.class.name,
          'file'      => file,
          'line'      => line,
          'source'    => source,
          'snippet'   => snippet,
          'backtrace' => backtrace
        }
      }

      io.puts data.to_yaml
    end

    #
    def error(step, exception)
      super(step, exception)

      backtrace = sane_backtrace(exception)

      file, line = file_line(backtrace)
      file = localize_file(file)

      snippet = structured_code_snippet(exception, bredth=3)
      source  = snippet.map{ |h| h.values.first }[snippet.size / 2].strip

      data = {
        'type'        => 'test',
        'subtype'     => 'step',
        'status'      => 'error',
        'label'       => step.explain.strip,
        'file'        => localize_file(step.file),
        'line'        => step.explain_lineno,
        #'returned'    => nil,
        #'expected'    => nil,
        'time'        => time_since_start,
        'exception'   => {
          'message'   => exception.message, #unansi
          'class'     => exception.class.name,
          'file'      => file,
          'line'      => line,
          'source'    => source,
          'snippet'   => snippet,
          'backtrace' => backtrace
        }
      }

      io.puts data.to_yaml
    end

    #
    def after_session(session)
      pass_size = steps.size - (fails.size + errors.size + omits.size)

      data = {
        'type'   => 'final',
        'time' => time_since_start,
        'counts' => {
           'total' => steps.size,
           'pass'  => pass_size,
           'fail'  => fails.size,
           'error' => errors.size,
           'omit'  => omits.size,
           'todo'  => 0
         }
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
