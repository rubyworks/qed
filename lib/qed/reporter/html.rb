# encoding: UTF-8

module QED
module Reporter

  require 'qed/reporter/abstract'

  # = Html Reporter
  #
  # NOTE: This must be completely redesigned since we moved back
  # to text based evaluation --which makes generting HTML with 
  # modifications from the evaluation tricky. But I've come up
  # with a farily clever way to handle this. Take the original
  # and use Tilt to translate it into HTML, then take the
  # evaluation results for code steps and use it to search
  # the HTML for "the closest match". Find the \<pre> tag
  # associated with the text and add class and color style.
  # Of course the tricky part is the matching, but if we
  # run the text snippet through Tilt as well we should be
  # able to get an exact match. It won't be fast, but it should
  # work.

  class Html < Abstract

    #
    def initialize(*args)
      require 'erb'

      begin
        require 'rubygems'
        gem 'rdoc'
        require 'rdoc'
      rescue
      end

      super(*args)
    end

    #
    def before_session(session)
      io.puts <<-END
        <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
          <title>QED Report</title>
          <style>
            body{width:800px; margin:0 auto;}
            pre{font-family: courier,monospace;}
            .pass{color: #020;}
            .pass pre{color: green;}
            .fail{color: #200; background: pink;}
            .fail pre{color: green;}
            .error{color: #200; background: pink;}
            .error pre{color: red;}
          </style>
        </head>
        <body>
      END
    end

    #
    def before_demo(demo)
      io.puts <<-END
        <h2>#{localize_file(demo.file)}</h2>
      END
    end

    def step(step)
      @_explain = step.explain.dup
    end

    #
    def match(step, md)
      #@match = md
      unless md[0].empty?
        @_explain.sub!(md[0], "<b>#{md[0]}</b>")
      end
    end

    #
    def pass(step)
      io.puts <<-END
        <div class="test pass">
          #{render(@_explain)}

          <pre>#{step.example}</pre>
        </div>
      END
    end

    #
    def fail(step, assertion)
      io.puts ERB.new(<<-END).result(binding)
        <div class="test fail">
          #{render(@_explain)}

          <pre>#{step.example}</pre>

          <div class="assertion">
            <p>#{assertion.class} - #{assertion.message}</p>
            <ol>
            <% assertion.backtrace.each do |bt| %>
              <li><%= bt %></li>
            <% end %>
            </ol>
          </div>
        </div>
      END
    end

    #
    def error(step, exception)
      io.puts ERB.new(<<-END).result(binding)
        <div class="test error">
          #{render(@_explain)}

          <pre>#{step.example}</pre>

          <div class="exception">
            <p>#{exception.class} - #{exception.message}</p>
            <ol>
            <% exception.backtrace.each do |bt| %>
              <li><%= bt %></li>
            <% end %>
            </ol>
          </div>
        </div>
      END
    end

    #
    def after_demo(demo)
    end

    #
    def after_session(session)
      io.puts <<-END
        </body>
        </html>
      END
    end

  private

    def render(str)
      rdoc.convert(str.strip)
    end

    def rdoc
      @rdoc ||= RDoc::Markup::ToHtml.new
    end

    #def h(str)
    #  ERB::Util.html_escape(str)
    #end
  end

end#module Reporter
end#module QED

