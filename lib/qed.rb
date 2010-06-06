module QED
  vers = YAML.load(File.read(File.dirname(__FILE__) + '/ae/version.yml'))
  VERSION = vers.values_at('major', 'minor', 'patch', 'state', 'build').compact.join('.')
end

require 'qed/session'

