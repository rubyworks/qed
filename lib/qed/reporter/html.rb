module QED
module Reporter #:nodoc:

  require 'qed/reporter/abstract'

  # = Html Reporter
  #
  class Html < Abstract

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

