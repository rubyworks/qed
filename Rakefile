#!/usr/bin/env ruby

desc "Run test demonstrations"
task 'demo' do
  sh "qed"
end

# NOTE: We can't use the qed simplecov profile in the `.config.rb`
# file b/c simplecov must be loaded before the code it covers.
# So we handle it all here instead.
desc "Run test demonstrations with coverage report"
task 'demo:cov' do
  require 'simplecov'
  SimpleCov.command_name 'demo'
  SimpleCov.start do
    coverage_dir 'log/coverage'
    #add_group "Label", "lib/qed/directory"
  end
  require 'qed/cli'
  QED::Session.cli
end


