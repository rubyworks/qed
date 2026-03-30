require 'rake/clean'

CLEAN.include('tmp', 'log', 'web/demo.html', 'pkg')

desc "Run QED demos [default]"
task :demo do
  sh "ruby -Ilib bin/qed"
end

desc "Run QED demos with coverage report"
task :'demo:cov' do
  require 'simplecov'
  SimpleCov.command_name 'demo'
  SimpleCov.start do
    coverage_dir 'log/coverage'
  end
  require 'qed/cli'
  QED::Session.cli
end

desc "Generate HTML documentation from demos"
task :qedoc do
  sh "ruby -Ilib bin/qedoc -o web/demo.html -t 'QED Demonstrandum' demo/"
end

desc "Build gem package"
task :build do
  sh "gem build qed.gemspec"
  mkdir_p 'pkg'
  mv Dir['*.gem'], 'pkg/'
end

desc "Build and install gem locally"
task :install => :build do
  sh "gem install pkg/qed-*.gem"
end

desc "Push gem to RubyGems.org"
task :release => :build do
  sh "gem push pkg/qed-*.gem"
end

task :default => :demo
