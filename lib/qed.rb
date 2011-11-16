module QED

  # Access to project metadata.
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/qed.yml')) rescue {}
    )
  end

  # Access to project metadata as constants.
  def self.const_missing(name)
    key = name.to_s.downcase
    metadata[key] || super(name)
  end

  # TODO: Only b/c of Ruby 1.8.x bug.
  VERSION = metadata['version']

end

require 'qed/session'
require 'qed/document'

