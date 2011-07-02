--- !ruby/object:Gem::Specification 
name: qed
version: !ruby/object:Gem::Version 
  prerelease: 
  version: 2.6.1
platform: ruby
authors: 
- Thomas Sawyer <transfire@gmail.com>
autorequire: 
bindir: bin
cert_chain: []

date: 2011-07-02 00:00:00 Z
dependencies: 
- !ruby/object:Gem::Dependency 
  name: ansi
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :runtime
  version_requirements: *id001
- !ruby/object:Gem::Dependency 
  name: facets
  prerelease: false
  requirement: &id002 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "2.8"
  type: :runtime
  version_requirements: *id002
- !ruby/object:Gem::Dependency 
  name: ae
  prerelease: false
  requirement: &id003 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "1.7"
  type: :runtime
  version_requirements: *id003
- !ruby/object:Gem::Dependency 
  name: detroit
  prerelease: false
  requirement: &id004 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
  type: :development
  version_requirements: *id004
description: QED (Quality Ensured Demonstrations) is a TDD/BDD framework utilizing Literate Programming techniques.
email: transfire@gmail.com
executables: 
- qedoc
- qed
extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- .ruby
- .yardopts
- bin/qed
- bin/qedoc
- lib/qed/advice.rb
- lib/qed/applique.rb
- lib/qed/cli/qedoc.rb
- lib/qed/core_ext.rb
- lib/qed/demo.rb
- lib/qed/document/jquery.js
- lib/qed/document/markup.rb
- lib/qed/document/template.rhtml
- lib/qed/document.rb
- lib/qed/evaluator.rb
- lib/qed/helpers/file_fixtures.rb
- lib/qed/helpers/shell_session.rb
- lib/qed/parser.rb
- lib/qed/reporter/abstract.rb
- lib/qed/reporter/bullet.rb
- lib/qed/reporter/dotprogress.rb
- lib/qed/reporter/dtrace.rb
- lib/qed/reporter/html.rb
- lib/qed/reporter/tapy.rb
- lib/qed/reporter/verbatim.rb
- lib/qed/scope.rb
- lib/qed/session.rb
- lib/qed/settings.rb
- lib/qed.rb
- lib/qed.yml
- lib/yard-qed.rb
- qed/01_demos.rdoc
- qed/02_advice.rdoc
- qed/03_helpers.rdoc
- qed/04_samples.rdoc
- qed/05_quote.rdoc
- qed/07_toplevel.rdoc
- qed/08_cross_script.rdoc
- qed/09_cross_script.rdoc
- qed/10_constant_lookup.rdoc
- qed/applique/constant.rb
- qed/applique/env.rb
- qed/applique/fileutils.rb
- qed/applique/markup.rb
- qed/applique/quote.rb
- qed/applique/toplevel.rb
- qed/helpers/advice.rb
- qed/helpers/sample.rb
- qed/helpers/toplevel.rb
- qed/samples/data.txt
- qed/samples/table.yml
- test/integration/topcode.rdoc
- HISTORY.rdoc
- README.rdoc
- QED.rdoc
- LICENSE.rdoc
homepage: http://rubyworks.github.com/qed
licenses: []

post_install_message: 
rdoc_options: 
- --title
- QED API
- --main
- README.rdoc
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
requirements: []

rubyforge_project: qed
rubygems_version: 1.8.2
signing_key: 
specification_version: 3
summary: Quod Erat Demonstrandum
test_files: []

