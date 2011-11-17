module QED
  module Step

    # Embedded after advice.
    #
    class After < Base

      #
      def evaluate(demo)
        demo.scope.instance_eval(<<-END, file, lineno)
          After do
            #{code}
          end
        END
      end

    end

  end
end
