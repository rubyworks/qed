module QED
  module Step
    #
    class When < Base

      # Evaluate given-step in context of the provided demo.
      #
      def evaluate(demo)
        match = rule_text

        #if match.start_with?('/') && match.end_with?('/')
        #  match = [Regex.new(match[1...-1])]
        #else
        #  match = match.split('...').map{ |e| e.strip }
        #end

        match = match.split('...').map{ |e| e.strip }

        if data?
          demo.scope.instance_eval(<<-END, file, lineno)
            When *#{match.inspect} do |match, data|
              #{code}
            end
          END
        else
          demo.scope.instance_eval(<<-END, file, lineno)
            When *#{match.inspect} do |match|
              #{code}
            end
          END
        end
      end

    end
  end
end
