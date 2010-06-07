module QED
module Reporter

  require 'qed/reporter/abstract'

  # = Html Reporter
  #
  # TODO: This must be completely redesigned since we moved back
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
      raise "HTML format is not currently working"
    end

    #
    def pass(step)
      step['class'] = 'pass'           # TODO add class not replace
      step['style'] = 'color: green;'  # TODO add style not replace
    end

    #
    def fail(step, assertion)
      step['class'] = 'fail'           # TODO add class not replace
      step['style'] = 'color: red;'    # TODO add style not replace

      msg = "\n"
      msg << "  ##### FAIL #####\n"
      msg << "  # " + assertion.to_s
      msg << "\n"

      step.add_child(Nokogiri::HTML.fragment(msg))
    end

    #
    def error(step, exception)
      raise exception if $DEBUG

      step['class'] = 'error'          # TODO add class not replace
      step['style'] = 'color: red;'    # TODO add style not replace

      msg = "\n"
      msg << "  ##### ERROR #####\n"
      msg << "  # " + exception.to_s + "\n"
      msg << "  # " + exception.backtrace[0]
      msg << "\n"

      step.add_child(Nokogiri::HTML.fragment(msg))
    end

    #
    def after_document(demo)
      io.puts demo.document.to_s
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  io.puts str.strip
    #end

  end

end#module Reporter
end#module QED

