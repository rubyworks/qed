if RUBY_VERSION < '1.9'
  require 'qed/cli/qed'
  require 'qed/cli/qedoc'
else
  require_relative('cli/qed')
  require_relative('cli/qedoc')
end

