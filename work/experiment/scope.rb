#require_relative 'assertor'

module AE

  def self.hello?
    "here"
  end

  class Assertor < BasicObject

    def compare_message
      AE.hello?
    end

  end

end

def assert
  AE::Assertor.new.compare_message
end

class Scope < Module

  def initialize
    super()
  end

  def doit
    assert
  end

end
