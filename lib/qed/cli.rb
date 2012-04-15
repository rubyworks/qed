if RUBY_VERSION < '1.9'
  require 'qed/rc' unless ENV['norc']
  require 'qed/cli/qed'
  require 'qed/cli/qedoc'
else
  require_relative 'rc' unless ENV['norc']
  require_relative('cli/qed')
  require_relative('cli/qedoc')
end

