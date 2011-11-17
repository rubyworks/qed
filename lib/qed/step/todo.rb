module QED
  module Step

    # A step marked "todo".
    class Todo < Base

      # Pending step does no evaluation.
      def evaluate(demo)
        #demo.evaluate(code, lineno) if code?
      end

    end

  end
end
