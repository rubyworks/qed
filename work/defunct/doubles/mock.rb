module QED

  # = Mock
  #
  class Mock < Module
    attr :object

    def initialize
      super()
      @table = {}
    end

    #
    def __table__ ; @table ; end

    # TODO: Ruby has retry, but I need continue!
    def method_missing(meth, *args, &block)
      table     = @table
      interface = [meth, args, block_given?]

      table[interface] = nil

      define_method(meth) do |*args|
        result = super
        result.assert == table[interface]
        return result
      end

      Setter.new(table, interface)
    end

    #
    class Setter
      def initialize(table, interface)
        @table     = table
        @interface = interface
      end

      def ==(result)
        @table[@interface] = result
      end
    end

    # = Mock::Delegator
    #
    class Delegator
      instance_methods(true).each{ |m| protected m unless m.to_s =~ /^__/ }

      def initialize(object, mock_module)
        @instance_delegate = object
        extend(mock_module)
      end

      def method_missing(s, *a, &b)
        @instance_delegate.__send__(s, *a, &b)
      end
    end#class Delegator

  end#class Mock

  class ::Object
    # Create mock object.
    def mock(mock_module=nil)
      if mock_module
        Mock::Delegator.new(self, mock_module)
      else
        @_mock ||= Mock.new
        extend(@_mock)
        @_mock
      end
    end

    # We can't remove the module per-say.  So we have to
    # just neuter it. This is a very weak solution, but
    # it will suffice for the moment.
    #--
    # TODO: Use Carats for #unmix.
    #++
    def remove_mock(mock_module=nil)
      mock_module ||= @_mock
      obj = self
      mod = Module.new
      mock_module.__table__.each do |interface, result|
        meth = interface[0]
        mod.module_eval do
          define_method(meth, &obj.class.instance_method(meth).bind(obj))
        end
      end
      extend(mod)
    end
  end#class ::Object

end#module Quarry

