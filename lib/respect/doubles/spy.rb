raise "Spy class is under construction"

module Respect

  # = Spy
  #
  # Spy (aka DuckHunter) is a decoy object which is dropped into
  # methods which records the calls made against it --hence a method probe.
  # Of course, it is not perfect --an inescapable matter it seems for any
  # internal probe. There are a couple of issues related to conditionals.
  # Since the method test for a certain condition against the decoy, how
  # is the decoy to respond? Thus ceratin paths in the code may never get
  # exceuted and thus go unmapped. If Ruby had better conditional reflection
  # (i.e. if 'if', 'case', 'unless', 'when', etc. were true methods) then
  # this could be fixed by making the Probe reentrant, mapping out variant
  # true/false/nil replies. The likely insurmountable problem though is the
  # Halting problem. A probe can cause some methods to complete execution.
  # It's pretty rare, but it can happen and little can be done about it (I think).
  #
  # Note, the alternative to this kind of probe is a program that examines, rather
  # then executes, the code. This would circumvent the above problems, but run
  # into difficulties with dynamic evals. It would also be more complicated,
  # but might prove a better means in the future.
  #
  # This script is provided for experimetnal purposes. Please inform the author
  # if you find ways to improve it or put it to an interesting use.
  #
  # == Synopsis
  #
  #   require 'methodprobe'
  #
  #   def amethod(x)
  #     x + 1
  #   end
  #
  #   p method(:amethod).signiture
  #   p method(:amethod).signiture(:class)
  #   p method(:amethod).signiture(:pretty)
  #
  # produces
  #
  #   [["+"]]
  #   [{"+"=>[["Fixnum"]]}]
  #   [["+( Fixnum )"]]
  #
  class Spy

    def self.duckcall
      begin
        yield
      rescue TypeError => e
        self.send(e.message)
        retry
      end
    end

    attr_reader :ducks, :decoys

    def initialize
      @ducks, @decoys = {}, {}
    end

    def initialize_copy(from)
      initialize
    end

    def method_missing(aSym, *args)
      aSymStr = aSym.to_s

      # This will happen the first time
      @ducks[aSymStr] ||= [] #unless @ducks[aSymStr]
      @ducks[aSymStr] << args.collect { |a| "#{a.class}" }

      decoy = self.dup

      @decoys[aSymStr] ||= [] #unless @decoys[aSymStr]
      @decoys[aSymStr] << decoy

      # build proxy?
      #begin
      #  d = <<-HERE
      #    def self.#{aSymStr}(*args)
      #      # This will happen the subsequent times
      #      @ducks["#{aSymStr}"] << args.collect { |a| #{'"#{a.class}"'} }
      #      @ducks["#{aSymStr}"].uniq!
      #      decoy = self.dup
      #      @decoys["#{aSymStr}"] = [] unless @decoys["#{aSymStr}"]
      #      @decoys["#{aSymStr}"] << decoy
      #      decoy
      #    end
      #  HERE
      #  instance_eval d
      #rescue SyntaxError
      #  puts "This error may be avoidable by returning the failing duck type as the error message."
      #  raise
      #end

      decoy
    end

  end # class MethodProbe

end


class ::Method

  # Outputs migration information.
  def migration
    parameters = []; argc = self.arity
    if argc > 0
      argc.times { parameters << Quarry::Probe.new }
      Probe.duckcall { self.call(*parameters) }
    elsif argc < 0
      raise "(NYI) method takes unlimited arguments"
    end
    return parameters
  end
  private :migration

  # Outputs signiture information.
  def signature(detail=nil)
    ds = []
    case detail
    when :complete, :all, :full
      ds = migration
    when :class, :with_class
      migration.each { |dh| ds << dh.ducks }
    when :pp, :pretty, :prettyprint, :pretty_print
      migration.each do |dh|
        responders = []
        dh.ducks.each do |responder, argss|
          argss.each { |args| responders << "#{responder}( #{args.join(',')} )" }
        end
        ds << responders
      end
    else
      migration.each { |dh| ds << dh.ducks.keys }
    end
    return ds
  end

end





=begin test

  require 'test/unit'

  # " I am a Duck Hunter ! "

  class TC_MethodProbe < Test::Unit::TestCase

    # fixture
    def amethod(x)
      x + 1
    end

    def test_signiture_default
      assert_nothing_raised {
        method(:amethod).signature
      }
    end

    def test_signiture_with_class
      assert_nothing_raised {
        method(:amethod).signature(:class)
      }
    end

    def test_signiture_pp
      assert_nothing_raised {
        method(:amethod).signature(:pp)
      }
    end

    def test_signiture_all
      assert_nothing_raised {
        method(:amethod).signature(:complete)
      }
    end

  end

=end

# Copyright (c) 2004,2008 Thomas Sawyer

