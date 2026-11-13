module YardSample

  # Doubles a number.
  #
  #   YardSample.double(2)  #=> 4
  #
  # @deprecated Use #twice instead.
  #   Scheduled for removal next year.
  #
  # @example Doubling a float
  #   YardSample.double(1.5)  #=> 3.0
  #
  # @return [Numeric] The number,
  #   times two.
  def self.double(n)
    n * 2
  end

end
