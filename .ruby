---
source:
- var
authors:
- name: Trans
  email: transfire@gmail.com
copyrights:
- holder: Thomas Sawyer, Rubyworks
  year: '2006'
  license: BSD-2-Clause
requirements:
- name: ansi
- name: brass
- name: facets
  version: 2.8+
- name: courtier
  groups:
  - optional
  development: true
- name: blankslate
  groups:
  - optional
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
- name: detroit
  groups:
  - build
  development: true
- name: fire
  groups:
  - build
  development: true
dependencies: []
alternatives: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/qed.git
  scm: git
  name: upstream
resources:
- uri: http://rubyworks.github.com/qed
  name: home
  type: home
- uri: http://github.com/rubyworks/qed
  name: code
  type: code
- uri: http://groups.google.com/groups/rubyworks-mailinglist
  name: mail
  type: mail
- uri: http://github.com/rubyworks/qed/issues
  name: bugs
  type: bugs
extra: {}
load_path:
- lib
revision: 0
created: '2009-06-16'
summary: Quod Erat Demonstrandum
title: QED
version: 2.9.0
name: qed
webcvs: http://github.com/rubyworks/qed/blob/master/
description: ! 'QED (Quality Ensured Demonstrations) is a TDD/BDD framework

  utilizing Literate Programming techniques.'
date: '2012-04-14'
