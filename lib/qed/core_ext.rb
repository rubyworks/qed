require 'brass'

class Object

  unless method_defined?(:instance_exec) # 1.9
    require 'thread'

    module InstanceExecMethods #:nodoc:
    end

    include InstanceExecMethods

    # Evaluate the block with the given arguments within the context of
    # this object, so self is set to the method receiver.
    #
    # From Mauricio's http://eigenclass.org/hiki/bounded+space+instance_exec
    #
    # This version has been borrowed from Rails for compatibility sake.
    def instance_exec(*args, &block)
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(method_name = "__instance_exec#{n}")
        InstanceExecMethods.module_eval { define_method(method_name, &block) }
      ensure
        Thread.critical = old_critical
      end

      begin
        send(method_name, *args)
      ensure
        InstanceExecMethods.module_eval { remove_method(method_name) } rescue nil
      end
    end
  end

  #
  # This is used by the `#=>` notation.
  #
  def must_return(value)
    assert(self == value, "#{self.inspect} #=> #{value.inspect}")
  end

end

class String

  # from facets
  def tabto(num=nil, opts={})
    raise ArgumentError, "String#margin has been renamed to #trim." unless num

    tab = opts[:tab] || 2
    str = gsub("\t", " " * tab)  # TODO: only leading tabs ?

    if opts[:lead]
      if self =~ /^( *)\S/
        indent(num - $1.length)
      else
        self
      end
    else
      min = []
      str.each_line do |line|
        next if line.strip.empty?
        min << line.index(/\S/)
      end
      min = min.min
      str.indent(num - min)
    end
  end

  # from facets
  def indent(n, c=' ')
    if n >= 0
      gsub(/^/, c * n)
    else
      gsub(/^#{Regexp.escape(c)}{0,#{-n}}/, "")
    end
  end

end
