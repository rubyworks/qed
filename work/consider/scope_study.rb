class S < Module

  def initialize
    super()
    extend self
    define_method(:__binding__) do
      @binding ||= binding
    end
  end

  #def __binding__
  #  @binding ||= binding
  #end

end


# Sample 1

s1 = S.new

s1.module_eval <<-END
  puts "\ns1"
  p self
  p self.class
  p self.object_id
  X = 10
  def x; 10; end
END

raise unless s1.x  == 10 rescue puts "s1.x  " + $!
raise unless s1::X == 10 rescue puts "s1::X " + $!


# Sample 2

s2 = S.new

eval(<<-END, s2.__binding__)
  puts "\ns2"
  p self
  p self.class
  p self.object_id
  X = 10
  def x; 10; end
  def q; 20; end
END

raise unless s2.x  == 10 rescue puts "s2.x  " + $!
raise unless s2.q  == 20 rescue puts "s2.y  " + $!
raise unless s2::X == 10 rescue puts "s2::X " + $!


# Sample 3

s3 = S.new

eval(<<-END, s3.__binding__)
  puts "\ns3"
  p self
  p self.class
  p self.object_id
END

raise unless s3.x  == 10 rescue puts "s3.x  " + $!
raise unless s3.q  == 20 rescue puts "s3.y  " + $!
raise unless s3::X == 10 rescue puts "s3::X " + $!

