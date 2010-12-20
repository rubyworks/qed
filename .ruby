--- 
name: qed
repositories: 
  public: git://github.com/proutils/qed.git
title: QED
requires: 
- group: []

  name: ansi
  version: 0+
- group: []

  name: facets
  version: 0+
- group: []

  name: ae
  version: 0+
- group: 
  - build
  name: syckle
  version: 0+
resources: 
  home: http://proutils.github.com/qed
  work: http://github.com/proutils/qed
pom_verison: 1.0.0
manifest: 
- .ruby
- bin/qed
- bin/qedoc
- eg/hello_world.rdoc
- eg/view_error.rdoc
- eg/website.rdoc
- lib/qed/advice.rb
- lib/qed/applique.rb
- lib/qed/command.rb
- lib/qed/core_ext.rb
- lib/qed/demo.rb
- lib/qed/evaluator.rb
- lib/qed/helpers/file_fixtures.rb
- lib/qed/helpers/shell_session.rb
- lib/qed/parser.rb
- lib/qed/reporter/abstract.rb
- lib/qed/reporter/bullet.rb
- lib/qed/reporter/dotprogress.rb
- lib/qed/reporter/html.rb
- lib/qed/reporter/verbatim.rb
- lib/qed/scope.rb
- lib/qed/session.rb
- lib/qed.rb
- lib/qed.yml
- lib/qedoc/command.rb
- lib/qedoc/document/jquery.js
- lib/qedoc/document/markup.rb
- lib/qedoc/document/template.rhtml
- lib/qedoc/document.rb
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
- LICENSE
- README.rdoc
- History.rdoc
- Version
version: 2.5.0
copyright: Copyright (c) 2006 Thomas Sawyer
description: QED (Quality Ensured Demonstrations) is a TDD/BDD framework utilizing Literate Programming techniques.
organization: RubyWorks
summary: Quod Erat Demonstrandum
authors: 
- Thomas Sawyer <transfire@gmail.com>
created: 2006-12-16