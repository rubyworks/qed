module QED

  DIRECTORY = File.dirname(__FILE__)

  def self.package
    @package ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/package'))
    )
  end

  def self.profile
    @profile ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/profile'))
    )
  end

  def self.const_missing(name)
    key = name.to_s.downcase
    package[key] || profile[key] || super(name)
  end

end

# becuase Ruby 1.8~ gets in the way
Object.__send__(:remove_const, :VERSION) if Object.const_defined?(:VERSION)
