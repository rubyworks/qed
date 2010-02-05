module QED

  class Advice

    # Event advice: Before, After and Upon.
    #
    class Events

      #
      attr :signals

      #
      def initialize
        @signals = [{}]
      end

      #
      def add(type, &procedure)
        @signals.last[type.to_sym] = procedure
      end

      #
      def call(type, *args)
        @signals.each do |set|
          proc = set[type.to_sym]
          proc.call(*args) if proc
        end
      end

      # Clear last set of advice.
      def reset
        @signals.pop
      end

      #
      def setup
        @signals.push {}
      end

      # Clear advice.
      def clear(type=nil)
        if type
          @signals.each{ |set| set.delete(type.to_sym) }
        else
          @signals = [{}]
        end
      end

    end

  end

end

