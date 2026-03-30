require 'erb'
require 'kramdown'
require 'qed/reporter/abstract'

module QED
module Reporter

  # = Html Reporter
  #
  # Generates a self-contained HTML report of a QED session,
  # with color-coded pass/fail/error results.
  #
  class Html < Abstract

    def before_session(session)
      super(session)
      io.puts HTML_HEAD
    end

    def before_demo(demo)
      super(demo)
      io.puts %[<div class="demo">]
      io.puts %[<h2 class="demo-file">#{escape(localize_file(demo.file))}</h2>]
    end

    def step(step)
      @_explain = step.explain.dup
    end

    def match(step, md)
      unless md[0].empty?
        @_explain.sub!(md[0], "<mark>#{escape(md[0])}</mark>")
      end
    end

    def pass(step)
      super(step)
      io.puts %[<div class="step pass">]
      io.puts render(@_explain)
      if step.has_example?
        io.puts %[<pre class="code pass">#{escape(step.example)}</pre>]
      end
      io.puts %[</div>]
    end

    def fail(step, assertion)
      super(step, assertion)
      io.puts %[<div class="step fail">]
      io.puts render(@_explain)
      if step.has_example?
        io.puts %[<pre class="code fail">#{escape(step.example)}</pre>]
      end
      io.puts %[<div class="details">]
      io.puts %[<p class="message">FAIL: #{escape(assertion.message)}</p>]
      io.puts %[<pre class="backtrace">#{escape(sane_backtrace(assertion).join("\n"))}</pre>]
      io.puts %[</div>]
      io.puts %[</div>]
    end

    def error(step, exception)
      super(step, exception)
      io.puts %[<div class="step error">]
      io.puts render(@_explain)
      if step.has_example?
        io.puts %[<pre class="code error">#{escape(step.example)}</pre>]
      end
      io.puts %[<div class="details">]
      io.puts %[<p class="message">ERROR: #{escape(exception.class.to_s)} - #{escape(exception.message)}</p>]
      io.puts %[<pre class="backtrace">#{escape(sane_backtrace(exception).join("\n"))}</pre>]
      io.puts %[</div>]
      io.puts %[</div>]
    end

    def after_demo(demo)
      super(demo)
      io.puts %[</div>]
    end

    def after_session(session)
      super(session)

      pass_count = passes.size
      fail_count = fails.size
      error_count = errors.size
      total = steps.size

      status = (fail_count + error_count) == 0 ? 'pass' : 'fail'

      io.puts %[<div class="summary #{status}">]
      io.puts %[<p>#{demos.size} demos, #{total} steps: #{fail_count} failures, #{error_count} errors</p>]
      io.puts %[<p class="time">Finished in %.5f seconds</p>] % [Time.now - @start_time]
      io.puts %[</div>]
      io.puts HTML_FOOT
    end

  private

    def render(str)
      Kramdown::Document.new(str.strip).to_html
    end

    def escape(str)
      ERB::Util.html_escape(str.to_s)
    end

    HTML_HEAD = <<~'HTML'
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>QED Report</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            max-width: 860px; margin: 2em auto; padding: 0 1em;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            font-size: 15px; line-height: 1.6; color: #24292e; background: #fff;
          }
          h1 { font-size: 1.6em; margin: 0 0 1em; padding-bottom: 0.3em; border-bottom: 1px solid #eaecef; }
          h2.demo-file {
            font-size: 1.1em; margin: 1.5em 0 0.5em; padding: 0.4em 0.6em;
            background: #f1f3f5; border-radius: 4px; font-family: monospace;
          }
          .step { margin: 0.5em 0; padding: 0.6em 0.8em; border-left: 3px solid #ddd; }
          .step.pass { border-left-color: #28a745; }
          .step.fail { border-left-color: #d73a49; background: #ffeef0; }
          .step.error { border-left-color: #b31d28; background: #ffeef0; }
          .step p { margin: 0.3em 0; }
          .step h1, .step h2, .step h3 { margin: 0.3em 0; font-size: 1.1em; }
          pre.code {
            margin: 0.4em 0; padding: 0.6em 0.8em;
            font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace;
            font-size: 13px; line-height: 1.45;
            background: #f6f8fa; border-radius: 4px; overflow-x: auto;
          }
          pre.code.pass { background: #f0fff0; color: #22863a; }
          pre.code.fail { background: #fff0f0; color: #b31d28; }
          pre.code.error { background: #fff0f0; color: #b31d28; }
          .details { margin: 0.4em 0; }
          .details .message { font-weight: 600; color: #d73a49; margin: 0.3em 0; }
          .details .backtrace {
            font-size: 12px; color: #6a737d; background: #fafbfc;
            padding: 0.5em; border-radius: 4px; white-space: pre-wrap;
          }
          .summary {
            margin: 2em 0 1em; padding: 0.8em 1em;
            border-radius: 4px; font-weight: 600;
          }
          .summary.pass { background: #dcffe4; color: #165c26; }
          .summary.fail { background: #ffeef0; color: #b31d28; }
          .summary .time { font-weight: normal; font-size: 0.9em; color: #586069; }
          mark { background: #fff3cd; padding: 0 2px; border-radius: 2px; }
        </style>
      </head>
      <body>
      <h1>QED Report</h1>
    HTML

    HTML_FOOT = <<~'HTML'
      </body>
      </html>
    HTML

  end

end
end
