BEGIN {
   module Kernel

     h = Hash.new

     define_method(:requiree) do
       h
     end

     r = method :require

     define_method(:require) do |a|
       r.call(a)
       h[a] = caller
     end

   end
}


def p(*args)
  super *(args << caller[0])
end

