module QED

  # Expiremntal quick parser.
  #
  # NOT USED YET!
  #
  class QuickParser #:nodoc:

    #
    def initialize(demo)
      @lines = demo.lines
    end

    #
    def parse
      flush  = true
      script = []

      @lines.each do |line|
        case line
        when /^\s/
          if flush
            script << "Test do\n"
          end
          script << line
          flush = false
        else
          if !flush
            script << "end"
          end
          script << "# " + line
          flush = true
        end
      end

      script.join()
    end

  end

end
