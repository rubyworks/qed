module QED

  # = Patter Advice (When)
  #
  # This class tracks When advice defined by demo scripts
  # and helpers. It is instantiated in Scope, so that
  # the advice methods will have access to the same
  # local binding and the demo scripts themselves.
  #
  class Patterns

    attr :when

    def initialize
      @when = []
    end

    #
    def add(patterns, &procedure)
      @when << [patterns, procedure]
    end

    #
    def call(match, *args)
      @when.each do |(patterns, proc)|
        compare = match
        matched = true
        params  = []
        patterns.each do |pattern|
          case pattern
          when Regexp
            regex = pattern
          else
            regex = when_string_to_regexp(pattern)
          end
          if md = regex.match(compare)
            params.concat(md[1..-1])
            compare = md.post_match
          else
            matched = false
            break
          end
        end
        if matched
          params += args
          proc.call(*params)
        end
      end
    end

  private

    # TODO: Now that we can use multi-patterns, we might not need this any more.
    def when_string_to_regexp(str)
      str = str.split(/(\(\(.*?\)\))(?!\))/).map{ |x|
        x =~ /\A\(\((.*)\)\)\z/ ? $1 : Regexp.escape(x)
      }.join
      str = str.gsub(/(\\\ )+/, '\s+')
      Regexp.new(str, Regexp::IGNORECASE)

      #rexps = []
      #str = str.gsub(/\(\((.*?)\)\)/) do |m|
      #  rexps << '(' + $1 + ')'
      #  "\0"
      #end
      #str = Regexp.escape(str)
      #rexps.each do |r|
      #  str = str.sub("\0", r)
      #end
      #str = str.gsub(/(\\\ )+/, '\s+')
      #Regexp.new(str, Regexp::IGNORECASE)
    end

  end

end

