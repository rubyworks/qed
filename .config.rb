# Confection based configuration.

config :qed do
  # default configuration
end

config :qed, :profile=>:simplecov, :preset=>true do
  require 'simplecov'
  SimpleCov.start do
    coverage_dir 'log/coverage'
    #add_group "Label", "lib/qed/directory"
  end
end

config :qed, :profile=>:example do
  puts ("*" * 78)
  puts

  at_exit do
    puts
    puts ("*" * 78)
  end
end

