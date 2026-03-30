require_relative 'lib/qed/version'

Gem::Specification.new do |s|
  s.name        = 'qed'
  s.version     = QED::VERSION
  s.summary     = 'Quod Erat Demonstrandum'
  s.description = 'QED (Quality Ensured Demonstrations) is a TDD/BDD framework utilizing Literate Programming techniques.'

  s.authors     = ['trans']
  s.email       = ['transfire@gmail.com']
  s.homepage    = 'https://github.com/rubyworks/qed'
  s.license     = 'BSD-2-Clause'

  s.required_ruby_version = '>= 3.1'

  s.files       = Dir['lib/**/*', 'bin/*', 'demo/**/*', 'HISTORY.md', 'README.md', 'LICENSE.txt', 'Gemfile']
  s.executables = ['qed', 'qedoc']

  s.add_runtime_dependency 'ansi'
  s.add_runtime_dependency 'brass'
  s.add_runtime_dependency 'kramdown'

  s.add_development_dependency 'ae'
end
