module QED
  module Step

    # Embedded before advice.
    #
    class Before < Base

      #
      def evaluate(demo)
        demo.scope.instance_eval(<<-END, file, lineno)
          Before do
            #{code}
          end
        END
      end

    end

  end
end
