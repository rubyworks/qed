module QED

  #
  def self.configure(name=nil, &block)
    name = (name || 'default').to_s
    profiles[name] = block if block
    profiles[name]
  end

  # Alias for configure.
  def self.profile(name=nil, &block)
    configure(name, &block)
  end

  #
  def self.profiles
    @profiles ||= {}
  end

end
