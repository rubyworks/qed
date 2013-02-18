# QED demo configuration

QED.configure 'cov' do
  require 'simplecov'
  SimpleCov.command_name 'demo'
  SimpleCov.start do
    add_filter '/demo/'
    coverage_dir 'log/coverage'
    #add_group "Label", "lib/qed/directory"
  end
end

# Just an an example.
QED.configure 'sample' do
  puts ("*" * 78)
  puts

  at_exit do
    puts
    puts ("*" * 78)
  end
end

