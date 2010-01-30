module QED
module Reporter #:nodoc:

  require 'qed/reporter/base'

  # = Html Reporter
  #
  class Html < BaseClass

    #
    def step_pass(step)
      step['class'] = 'pass'           # TODO add class not replace
      step['style'] = 'color: green;'  # TODO add style not replace
    end

    #
    def step_fail(step, assertion)
      step['class'] = 'fail'           # TODO add class not replace
      step['style'] = 'color: red;'    # TODO add style not replace

      msg = "\n"
      msg << "  ##### FAIL #####\n"
      msg << "  # " + assertion.to_s
      msg << "\n"

      step.add_child(Nokogiri::HTML.fragment(msg))
    end

    #
    def step_error(step, exception)
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

    def after_demonstration(demo)
      io.puts demo.nokogiri.to_s
    end

    #def report(str)
    #  count[-1] += 1 unless count.empty?
    #  str = str.chomp('.') + '.'
    #  str = count.join('.') + ' ' + str
    #  io.puts str.strip
    #end

  end #class Summary

end#module Reporter
end#module QED

