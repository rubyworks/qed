module QED

  # A Step consists of a flush region of text and the indented 
  # text the follows it. QED breaks all demo documents down into
  # these for evaluation.
  #
  # The Step module acts a factory class to produce subtype of steps.
  #
  module Step

    require 'qed/step/base'
    require 'qed/step/eval'
    require 'qed/step/before'
    require 'qed/step/after'
    require 'qed/step/rule'
    require 'qed/step/todo'

    #
    def self.factory(file, explain, example, last)
      if explain.first
        text = explain.first[1]
        type = (
          if md = /\A(\w+)[:.]\ /i.match(text)
            md[1].capitalize
          else
            'Eval'
          end
        )
      else
        type = 'Eval'
      end

      type = 'Rule' if type == 'When'

      const_get(type).new(file, explain, example, last)
    end

  end

end
