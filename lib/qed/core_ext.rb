require 'brass'

class Object

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
