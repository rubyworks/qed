module QED

  # = Advice
  #
  # This class tracks advice defined by demonstrandum
  # and applique. It is instantiated in Scope, so that
  # the advice methods will have access to the same
  # local binding as the scripts themselves.
  #
  # There are two types of advice: *pattern matchers*
  # and *event signals*.
  #
  # == Pattern Matchers (When)
  #
  # Matchers are evaluated when they match a blocks
  # commentary.
  #
  # == Event Signals (Before, After)
  #
  # Event advice are triggered on symbolic targets which 
  # represent an event in the evaluation process, such as
  # before an example is run, or after a demo finishes.
  #
  class Advice

    #
    attr :matchers

    #
    attr :signals

    #
    def initialize
      @matchers = []
      @signals  = [{}]
    end

    #
    def call(scope, type, *args)
      case type
      when :when
        call_matchers(scope, *args)
      else
        #@events.call(scope, type, *args)
        call_signals(scope, type, *args)
      end
    end

    #
    def add_event(type, &procedure)
      @signals.last[type.to_sym] = procedure
    end

    #
    def add_match(patterns, &procedure)
      @matchers << [patterns, procedure]
    end

    # React to an event.
    def call_signals(scope, type, *args)
      @signals.each do |set|
        proc = set[type.to_sym]
        #proc.call(*args) if proc
        scope.instance_exec(*args, &proc) if proc
      end
    end

    #
    def call_matchers(scope, section)
      match = section.commentary
      args  = section.arguments
      matchers.each do |(patterns, proc)|
        compare = match
        matched = true
        params  = []
        patterns.each do |pattern|
          case pattern
          when Regexp
            regex = pattern
          else
            regex = match_string_to_regexp(pattern)
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

    # Clear last set of advice.
    def signals_reset
      @signals.pop
    end

    #
    def signals_setup
      @signals.push({})
    end

    # Clear advice.
    def signals_clear(type=nil)
      if type
        @signals.each{ |set| set.delete(type.to_sym) }
      else
        @signals = [{}]
      end
    end

  private

    # Convert matching string into a regular expression. If the string
    # contains double parenthesis, such as ((.*?)), then the text within
    # them is treated as in regular expression and kept verbatium.
    #
    # TODO: Better way to isolate regexp. Maybe "?:(.*?)".
    #
    # TODO: Now that we can use multi-patterns, do we still need this?
    #
    def match_string_to_regexp(str)
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

