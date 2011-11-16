module AE

  def self.hello?
    "here"
  end

  class Assertor < BasicObject

    def compare_message
      AE.hello?
    end

    def self.const_missing(const)
      ::Object.const_get(const)
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
    p assert
  end

end

scope = Scope.new

scope.doit
