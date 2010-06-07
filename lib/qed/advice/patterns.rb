module QED

  # = Pattern Advice (When)
  #
  # This class encapsulates "When" advice on plain text.
  #
  # Matches are evaluated in Scope context, via #instance_exec,
  # so that the advice methods will have access to the same
  # scope as the demonstrandum themselves.
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
    def call(scope, section)
      match = section.text
      args  = section.args

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
          #proc.call(*params)
          scope.instance_exec(*params, &proc)
        end
      end
    end

  private

    # TODO: Now that we can use multi-patterns, we might not need this any more.
    def when_string_to_regexp(str)
      str = str.split(/(\(\(.*?\)\))(?!\))/).map{ |x|
        x =~ /\A\(\((.*)\)\)\Z/ ? $1 : Regexp.escape(x)
      }.join
      str = str.gsub(/\\\s+/, '\s+')
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

