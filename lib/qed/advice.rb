module QED

  # = Advice
  #
  # This class tracks advice defined by demo scripts
  # and helpers. It is instantiated in Scope, so that
  # the advice methods will have access to the same
  # local binding and the demo scripts themselves.
  #
  class Advice

    attr :when

    attr :signal

    def initialize
      @when   = []
      @signal = {}
    end

    def add_when(pattern, &procedure)
      case pattern
      when Symbol
        add(pattern, &procedure)
      else
        @when << [pattern, procedure]
      end
    end

    #
    def add(type, &procedure)
      @signal[type.to_sym] = procedure
    end

    #
    def call(type, *args)
      case type
      when :when
        call_when(*args)
      else
        proc = @signal[type.to_sym]
        proc.call(*args) if proc
      end
    end

    #
    def call_when(match, *args)
      @when.each do |(pattern, proc)|
        case pattern
        when Regexp
          regex = pattern
        else
          regex = when_string_to_regexp(pattern)
        end
        if md = regex.match(match)
          proc.call(*md[1..-1])
        end
      end
    end

    # Clear advice.
    def reset(type=nil)
      case type
      when :when
        @when   = []
      when :all
        @signal = {}
        @when   = []
      else
        @signal = {}
      end
    end

  private

    #
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

  #
  module Advisable

    def __advice__
      @__advice__ ||= Advice.new
    end

    def When(pattern, &procedure)
      @__advice__.add_when(pattern, &procedure)
    end

    def Before(type=:code, &procedure)
      @__advice__.add(:"before_#{type}", &procedure)
    end

    def After(type=:code, &procedure)
      @__advice__.add(:"after_#{type}", &procedure)
    end

  end

end

